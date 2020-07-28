unit u_config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dynlibs, math, typinfo, FileUtil, Forms, Controls,
  Graphics, Dialogs, ComCtrls, ExtCtrls, StdCtrls, Buttons, dSQLdbBroker,
  ACBrConsultaCNPJ, ACBrPosPrinter, base64, u_libs, u_models, u_dm;

type
  TKindMsg = (kdSucess, kdAlert, kdNotify, kdError);

  { TfrmConfig }
  TfrmConfig = class(TForm)
    btnCertificado: TSpeedButton;
    btnCertificado1: TBitBtn;
    btnSalvar: TBitBtn;
    cbModelo: TComboBox;
    cbPorta: TComboBox;
    chgImpressora: TCheckGroup;
    edMargemAvista: TEdit;
    EditAbertura: TEdit;
    EditBairro: TEdit;
    EditCEP: TEdit;
    EditCertificado: TEdit;
    EditCidade: TEdit;
    EditCNAE1: TEdit;
    EditCNPJ: TEdit;
    EditComplemento: TEdit;
    EditCpfResponsavel: TEdit;
    EditEmail: TEdit;
    EditEndereco: TEdit;
    EditFantasia: TEdit;
    EditIdCSC: TEdit;
    EditInscricao: TEdit;
    EditNumero: TEdit;
    EditNumSerie: TEdit;
    EditRazaoSocial: TEdit;
    EditResponsavel: TEdit;
    EditSenha: TEdit;
    EditSituacao: TEdit;
    EditTelefone: TEdit;
    EditTipo: TEdit;
    EditTokenCSC: TEdit;
    EditUF: TEdit;
    EditValidade: TEdit;
    EditVelocidade: TComboBox;
    edMargemAprazo: TEdit;
    edTimeout: TEdit;
    gbFiscais: TGroupBox;
    gbImpressora: TGroupBox;
    GroupBox1: TGroupBox;
    gbMargens: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    DialogCertificado: TOpenDialog;
    Label31: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbMsg: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    pnExtras: TPanel;
    pnAvancadas: TPanel;
    pnControles: TPanel;
    pnMsg: TPanel;
    rgAmbiente: TRadioGroup;
    StatusBar1: TStatusBar;
    tabEmpresa: TTabSheet;
    tabAvancada: TTabSheet;
    tabExtra: TTabSheet;
    Timer: TTimer;
    procedure btnBuscarClick(Sender: TObject);
    procedure btnCertificado1Click(Sender: TObject);
    procedure btnCertificadoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure EditCEPKeyPress(Sender: TObject; var Key: char);
    procedure EditCNPJExit(Sender: TObject);
    procedure EditCNPJKeyPress(Sender: TObject; var Key: char);
    procedure EditCpfResponsavelKeyPress(Sender: TObject; var Key: char);
    procedure EditNumeroKeyPress(Sender: TObject; var Key: char);
    procedure EditRazaoSocialChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    procedure GetEmpresa;
    procedure GetConfig;
    procedure ModifyEmpresa;
    //procedure StartSearch(AFound: Boolean);
    //procedure BuscaCNPJ;
    procedure AbortAll;
    //procedure GetCaptchaBase64;
    function ResolveCapctha(Base64Str: string): String;
    function StreamToBase64(AStream: TStream): string;
    procedure Flash(AMessage: String; AkdMsg: TKindMsg = kdSucess);
  public
  end;

var
  frmConfig: TfrmConfig;

type
  TPtrResolve = function(Base64: String): ShortString; stdcall;

implementation

{$R *.lfm}

{ TfrmConfig }

procedure TfrmConfig.EditCNPJKeyPress(Sender: TObject; var Key: char);
begin
  Key := OnlyKeyCPForCNPJNumbers(Key);
end;

procedure TfrmConfig.EditCpfResponsavelKeyPress(Sender: TObject; var Key: char);
begin
  Key := OnlyKeyCPForCNPJNumbers(Key);
end;

procedure TfrmConfig.EditNumeroKeyPress(Sender: TObject; var Key: char);
begin
  Key := OnlyKeyNumbers(Key);
end;

procedure TfrmConfig.EditRazaoSocialChange(Sender: TObject);
begin
  btnSalvar.Enabled := (EditRazaoSocial.Text <> '');
end;

procedure TfrmConfig.FormCreate(Sender: TObject);
var
  ModeloImpressora: TACBrPosPrinterModelo;
begin
  // lista de impressoras suportadas
  cbModelo.Items.Clear ;
  For ModeloImpressora := Low(TACBrPosPrinterModelo) to High(TACBrPosPrinterModelo) do
    cbModelo.Items.Add(GetEnumName(TypeInfo(TACBrPosPrinterModelo), Integer(ModeloImpressora)));

  // portas COM disponíveis
  cbPorta.Items.BeginUpdate;
  try
    cbPorta.Items.Clear;
    dm.posPrinter.Device.AcharPortasSeriais(cbPorta.Items);
  finally
    cbPorta.Items.EndUpdate;
  end;
end;

procedure TfrmConfig.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 27) then Close;
end;

procedure TfrmConfig.FormShow(Sender: TObject);
begin
  GetEmpresa;
  GetConfig;
  tabEmpresa.SetFocus;
end;

procedure TfrmConfig.TimerTimer(Sender: TObject);
begin
  pnMsg.Hide;
end;

procedure TfrmConfig.GetEmpresa;
var
  Empresa: TEmpresa;
  Empresas: TMapEmpresas;
  Found: Boolean;
begin
  Found   := False;
  Empresa := TEmpresa.Create;
  Empresas := TMapEmpresas.Create(con, 'empresa');
  try
    Empresa.Id := 1;
    Empresas.Get(Empresa);

    if (Empresa.Cnpj.raw_numbers <> '') then
    begin
      EditCNPJ.Text             := Empresa.Cnpj.maskCpfCnpj;
      EditRazaoSocial.Text      := Empresa.Razao;
      EditAbertura.Text         := Empresa.Abertura.to_s;
      EditTipo.Text             := Empresa.Tipo_empresa;
      EditFantasia.Text         := Empresa.Fantasia;
      EditInscricao.Text        := Empresa.Insc;
      EditEndereco.Text         := Empresa.Endereco;
      EditNumero.Text           := Empresa.Numero.to_s;
      EditComplemento.Text      := Empresa.Complemento;
      EditBairro.Text           := Empresa.Bairro;
      EditTelefone.Text         := Empresa.Telefone.maskPhone;
      EditCidade.Text           := Empresa.Cidade;
      EditUF.Text               := Empresa.Uf;
      EditCEP.Text              := Empresa.Cep;
      EditSituacao.Text         := Empresa.Situacao;
      EditResponsavel.Text      := Empresa.Responsavel;
      EditCpfResponsavel.Text   := Empresa.Cpf_responsavel.maskCpfCnpj;
      EditEmail.Text            := Empresa.Email.down;
      EditCNAE1.Text            := Empresa.Cnae_1;
    end;
  finally
    Empresa.Free;
    Empresas.Free;
    //StartSearch(Found);
  end;
end;

procedure TfrmConfig.GetConfig;
var
  Configuracao: TConfiguracao;
  Configuracoes: TMapConfiguracoes;
begin
  Configuracao  := TConfiguracao.Create;
  Configuracoes := TMapConfiguracoes.Create(con, 'configuracoes');
  try
    Configuracao.Id := 1;
    Configuracoes.Get(Configuracao);
    EditCertificado.Text               := Configuracao.Path_certificado;
    EditSenha.Text                     := Decifra(16, '1046', Configuracao.Senha_certificado);
    EditNumSerie.Text                  := Configuracao.Serie_certificado;
    EditIdCSC.Text                     := Configuracao.Id_csc.to_s;
    EditTokenCSC.Text                  := Decifra(16, '1046', Configuracao.Token_csc);
    rgAmbiente.ItemIndex               := Configuracao.Ambiente - 1;
    cbModelo.ItemIndex                 := Configuracao.Modelo_impressora;
    EditVelocidade.Text                := Configuracao.Velocidade;
    edTimeout.Text                     := Configuracao.TimeOut.to_s;
    cbPorta.Text                       := Configuracao.Porta;
    chgImpressora.Checked[0]           := Configuracao.Corta_papel = 1;
    chgImpressora.Checked[1]           := Configuracao.Itens_uma_linha = 1;
    chgImpressora.Checked[2]           := Configuracao.Abre_gaveta = 1;
  finally
    Configuracao.Free;
    Configuracoes.Free;
  end;
end;

procedure TfrmConfig.ModifyEmpresa;
var
  Empresa: TEmpresa;
  Empresas: TMapEmpresas;
  Configuracao: TConfiguracao;
  Configuracoes: TMapConfiguracoes;
begin
  Empresa := TEmpresa.Create;
  Empresas := TMapEmpresas.Create(con, 'empresa');
  Configuracao := TConfiguracao.Create;
  Configuracoes := TMapConfiguracoes.Create(con, 'configuracoes');
  try
    Empresa.Id := 1;
    Empresas.Get(Empresa);
    Empresa.Cnpj                       := EditCNPJ.Text.raw_numbers;
    Empresa.Razao                      := EditRazaoSocial.Text.raw;
    Empresa.Tipo_empresa               := EditTipo.Text.raw;
    Empresa.Fantasia                   := EditFantasia.Text.raw;
    Empresa.Insc                       := EditInscricao.Text.raw_numbers;
    Empresa.Endereco                   := EditEndereco.Text.raw;
    Empresa.Numero                     := EditNumero.Text.to_i;
    Empresa.Complemento                := EditComplemento.Text.raw;
    Empresa.Bairro                     := EditBairro.Text.raw;
    Empresa.Telefone                   := EditTelefone.Text.raw_numbers;
    Empresa.Cidade                     := EditCidade.Text.raw;
    Empresa.Uf                         := Trim(EditUF.Text.raw);
    Empresa.Cep                        := EditCEP.Text.raw_numbers;
    Empresa.Situacao                   := EditSituacao.Text.raw;
    Empresa.Responsavel                := EditResponsavel.Text.raw;
    Empresa.Cpf_responsavel            := EditCpfResponsavel.Text.raw_numbers;
    Empresa.Email                      := EditEmail.Text.raw;
    Empresa.Cnae_1                     := EditCNAE1.Text.raw;

    Configuracao.Id := 1;
    Configuracoes.Get(Configuracao);
    Configuracao.Path_certificado      := EditCertificado.Text;
    Configuracao.Senha_certificado     := cifra(16, '1046', EditSenha.Text);
    Configuracao.Serie_certificado     := EditNumSerie.Text;
    Configuracao.Id_csc                := EditIdCSC.Text.to_i;
    Configuracao.Token_csc             := cifra(16, '1046',  EditTokenCSC.Text);
    Configuracao.Ambiente              := rgAmbiente.ItemIndex + 1;
    Configuracao.Modelo_impressora     := cbModelo.ItemIndex;
    Configuracao.Velocidade            := EditVelocidade.Text;
    Configuracao.Porta                 := cbPorta.Text;
    Configuracao.TimeOut               := edTimeout.Text.to_i;
    Configuracao.Corta_papel           := ifthen(chgImpressora.Checked[0], 1, 0);
    Configuracao.Itens_uma_linha       := ifthen(chgImpressora.Checked[1], 1, 0);
    Configuracao.Abre_gaveta           := ifthen(chgImpressora.Checked[2], 1, 0);

    Empresas.Modify(Empresa);
    Configuracoes.Modify(Configuracao);
    Empresas.Apply;
    Configuracoes.Apply;
  finally
    Empresa.Free;
    Empresas.Free;
    Configuracao.Free;
    Configuracoes.Free;
    dm.GetConfigs;
    Flash('Operação realizada com sucesso!');
  end;
end;

//procedure TfrmConfig.StartSearch(AFound: Boolean);
//begin
//  if AFound then Exit;
//  //GetCaptchaBase64;
//end;

function TfrmConfig.ResolveCapctha(Base64Str: string): String;
var
  lHandle: TLibHandle;
  DoGetResolve: TPtrResolve;
begin
  Result := '';
  {$IFDEF MSWINDOWS}
    lHandle := SafeLoadLibrary('choco.dll');
  {$ENDIF}
  {$IFDEF UNIX}
    lHandle := SafeLoadLibrary('libchoco.so');
  {$ENDIF}
  if lHandle = NilHandle then
    Exit;
  try
    DoGetResolve := TPtrResolve(GetProcAddress(lHandle, 'resolveCaptcha'));
    if @DoGetResolve <> Nil then
      Result := DoGetResolve(Base64Str);
  finally
    FreeLibrary(lHandle);
  end;
end;

//procedure TfrmConfig.BuscaCNPJ;
//var
//  VCaptcha: String;
//begin
  //if (Label1.Caption <> '') then
  //  VCaptcha := ResolveCapctha(Label1.Caption)
  //else
  //  AbortAll;
  //if (VCaptcha = '') then AbortAll;
  //
  //if cnpj.Consulta(EditCNPJ.Text.raw_numbers, VCaptcha) then
  //begin
  //  EditTipo.Text              := cnpj.EmpresaTipo;
  //  EditRazaoSocial.Text       := cnpj.RazaoSocial;
  //  EditAbertura.Text          := DateToStr(cnpj.Abertura);
  //  EditFantasia.Text          := cnpj.Fantasia;
  //  EditEndereco.Text          := cnpj.Endereco;
  //  EditNumero.Text            := cnpj.Numero;
  //  EditComplemento.Text       := cnpj.Complemento;
  //  EditBairro.Text            := cnpj.Bairro;
  //  EditComplemento.Text       := cnpj.Complemento;
  //  EditCidade.Text            := cnpj.Cidade;
  //  EditUF.Text                := cnpj.UF;
  //  EditCEP.Text               := cnpj.CEP;
  //  EditSituacao.Text          := cnpj.Situacao;
  //  EditCNAE1.Text             := cnpj.CNAE1;
  //  lbMsg.Caption              := '';
  //end
  //else
  //  AbortAll;
//end;

procedure TfrmConfig.AbortAll;
begin
  ShowMessage('Não foi possível realizar a busca dinâmica.'+#13+
              'Por favor, digite tudo e salve em seguida!');
end;

//procedure TfrmConfig.GetCaptchaBase64;
//var
//  Stream: TMemoryStream;
//  AText: String;
//begin
//  Stream:= TMemoryStream.Create;
//  try
//    cnpj.Captcha(Stream);
//    Stream.Position := 0;
//    AText := StreamToBase64(Stream);
//  finally
//    Label1.Caption := AText;
//    btnBuscar.Visible := True;
//    Stream.Free;
//  end;
//end;

function TfrmConfig.StreamToBase64(AStream: TStream): string;
var
  VDestStream: TStringStream;
begin
  VDestStream := TStringStream.Create('');
  try
    with TBase64EncodingStream.Create(VDestStream) do
    try
      CopyFrom(AStream, AStream.Size);
    finally
      Free;
    end;
    Result := VDestStream.DataString;
  finally
    VDestStream.Free;
  end;
end;

procedure TfrmConfig.Flash(AMessage: String; AkdMsg: TKindMsg);
begin
  case AkdMsg of
    kdSucess: begin
      pnMsg.Color      := $00E6F5D2;
      pnMsg.Font.Color := $00489217;
    end;
    kdNotify: begin
      pnMsg.Color      := $00FFE0D0;
      pnMsg.Font.Color := $00DD842E;
    end;
    kdAlert: begin
      pnMsg.Color      := $00DFF8FF;
      pnMsg.Font.Color := $0000A8FF;
    end;
    kdError: begin
      pnMsg.Color      := $00EFF2FF;
      pnMsg.Font.Color := $000000F7;
      Beep;
    end;
  end;
  pnMsg.Caption := AMessage;
  pnMsg.Show;
  Timer.Enabled := True;
end;

procedure TfrmConfig.EditCNPJExit(Sender: TObject);
begin
  EditCNPJ.Text := EditCNPJ.Text.maskCpfCnpj;
end;

procedure TfrmConfig.btnBuscarClick(Sender: TObject);
begin
  lbMsg.Caption := 'Aguarde...';
  Application.ProcessMessages;
  //BuscaCNPJ;
end;

procedure TfrmConfig.btnCertificado1Click(Sender: TObject);
begin
  if (EditCertificado.Text = '') or (EditSenha.Text = '') then
  begin
    ShowMessage('Preencha os campos de certficado e senha, por favor!');
    Exit;
  end;
  dm.nfe.Configuracoes.Certificados.ArquivoPFX := EditCertificado.Text;
  dm.nfe.Configuracoes.Certificados.Senha      := EditSenha.Text;
  EditValidade.Text := DateToStr(dm.nfe.SSL.CertDataVenc);
  EditNumSerie.Text := dm.nfe.SSL.CertNumeroSerie;
end;

procedure TfrmConfig.btnCertificadoClick(Sender: TObject);
begin
  if DialogCertificado.Execute then
    EditCertificado.Text := DialogCertificado.FileName;
end;

procedure TfrmConfig.btnSalvarClick(Sender: TObject);
begin
  if MessageDlg('Tem certeza que deseja salvar as alterações?', mtConfirmation, [mbYes, mbNo],0) = mrYes then
  ModifyEmpresa;
end;

procedure TfrmConfig.EditCEPKeyPress(Sender: TObject; var Key: char);
begin
  Key := OnlykeyCEPNumbers(Key);
end;

end.

