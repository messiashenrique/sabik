unit u_main;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF MSWINDOWS}
    windows,
  {$ENDIF}
  Classes, SysUtils, math, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  ExtCtrls, Buttons, ComCtrls, ActnList, LMessages, StdCtrls, TDIClass,
  dSQLdbBroker, dUtils, process, FBAdmin, u_libs, u_usuarios, u_fornecedores,
  u_clientes, u_grupos, u_produtos, u_entradas, u_vendas, u_dfs, u_relatorios,
  u_rules, u_gateway, u_models, u_config, u_caixa, u_dm, u_checkout, PinPTBR,
  PinAppUpdate, pingrid;

type

  { TThreadBackup }

  TThreadBackup = class(TThread)
  private
    FActive: Boolean;
    FMsg: String;
    procedure StartAnime;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean = False);
    destructor Destroy; override;
  end;


  { TThreadEnviaNFCe }

  TThreadEnviaNFCe = class(TThread)
  private
    procedure AtualizaFormDF;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean = False);
    destructor Destroy; override;
  end;



  { TfrmMain }
  TfrmMain = class(TForm)
    aclMain: TActionList;
    acProdutos: TAction;
    acGrupos: TAction;
    acFornecedores: TAction;
    acBalanco: TAction;
    acFazerBackup: TAction;
    acConfiguracoes: TAction;
    acCaixa: TAction;
    acNFCe: TAction;
    acUsuarios: TAction;
    acVendas: TAction;
    acEntradas: TAction;
    acRelatorios: TAction;
    acClientes: TAction;
    btnGoBackup: TBitBtn;
    btnUpdate: TBitBtn;
    btnNotUpdate: TBitBtn;
    Button1: TButton;
    gbCompromissos: TGroupBox;
//    gridLista: TPinGrid;
    img48: TImageList;
    img16: TImageList;
    img24: TImageList;
    lbDev: TLabel;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    mnProdutos: TMenuItem;
    mnFornecedores: TMenuItem;
    mnUsuarios: TMenuItem;
    mnMain: TMainMenu;
    MenuItem1: TMenuItem;
    mnCliente: TMenuItem;
    mnGrupos: TMenuItem;
    pnCompromissos: TPanel;
    pbar: TProgressBar;
    pnTotal: TPanel;
    ptbr: TPinPTBR;
    sb: TStatusBar;
    tbMain: TToolBar;
    tdi: TTDINoteBook;
    TimerNFCe: TTimer;
    timerUp: TTimer;
    timerBackup: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    up: TPinAppUpdate;
    procedure acBalancoExecute(Sender: TObject);
    procedure acCaixaExecute(Sender: TObject);
    procedure acClientesExecute(Sender: TObject);
    procedure acConfiguracoesExecute(Sender: TObject);
    procedure acEntradasExecute(Sender: TObject);
    procedure acFazerBackupExecute(Sender: TObject);
    procedure acFornecedoresExecute(Sender: TObject);
    procedure acGruposExecute(Sender: TObject);
    procedure acNFCeExecute(Sender: TObject);
    procedure acProdutosExecute(Sender: TObject);
    procedure acRelatoriosExecute(Sender: TObject);
    procedure acUsuariosExecute(Sender: TObject);
    procedure acVendasExecute(Sender: TObject);
    procedure btnGoBackupClick(Sender: TObject);
    procedure btnNotUpdateClick(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure mnClienteClick(Sender: TObject);
    procedure sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure timerBackupTimer(Sender: TObject);
    procedure TimerNFCeTimer(Sender: TObject);
    procedure timerUpTimer(Sender: TObject);
    procedure upDownloadProgress(Sender: TObject; Percent: Integer);
  private
    procedure IniciaAtualizacao;
    procedure VerificaAtualizacao;
    procedure VerificaBackup;
  public
    function IsShortcut(var Message: TLMKey): boolean; override;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TThreadEnviaNFCe }

procedure TThreadEnviaNFCe.AtualizaFormDF;
begin
  if Assigned(frmDFs) then frmDFs.CallSearchDefault;
end;

procedure TThreadEnviaNFCe.Execute;
var
  qry: TdSQLdbQuery;
  DF: TDocumentoFiscal;
  DFs: TMapDocumentoFiscal;
begin
  qry := TdSQLdbQuery.Create(con);
  DF := TDocumentoFiscal.Create;
  qry.SQL.Text := 'select first 1 * from documento_fiscal where (cstat=0 and tpemis=9)';
  try
    qry.Open;
    if not qry.IsEmpty then
    begin
      dUtils.dGetFields(DF, qry.Fields);
      dm.nfe.NotasFiscais.Clear;
      dm.nfe.NotasFiscais.LoadFromFile(DF.Path_xml);
      if dm.nfe.Enviar(1, False, True) then
      begin
        DF.cStat    := dm.nfe.NotasFiscais.Items[0].NFe.procNFe.cStat;
        DF.nProt    := dm.nfe.NotasFiscais.Items[0].NFe.procNFe.nProt;
        DF.dhRecbto := dm.nfe.NotasFiscais.Items[0].NFe.procNFe.dhRecbto;
        DF.xMotivo  := dm.nfe.NotasFiscais.Items[0].NFe.procNFe.xMotivo;
        DFs := TMapDocumentoFiscal.Create(con, 'documento_fiscal');
        try
          DFs.Modify(DF);
          DFs.Apply;
          {=== Atualiza o formulário de Documentos Fiscais ===}
          Synchronize(@AtualizaFormDF);
        finally
          DFs.Free;
        end;
      end;
    end;
  finally
    DF.Free;
    qry.Free;
  end;
end;

constructor TThreadEnviaNFCe.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

destructor TThreadEnviaNFCe.Destroy;
begin
  inherited Destroy;
end;

{ TThreadBackup }

procedure TThreadBackup.StartAnime;
begin
  frmMain.sb.Panels.Items[1].Text := FMsg;
//  frmMain.lbStatusBackup.Refresh;
end;

procedure TThreadBackup.Execute;
var
  MyBd, MyFilenameBackup, MyBackup: String;
  Backup: TInfo;
  Backups: TMapInfos;
  Command: TProcess;
begin
  FActive := False;
  FMsg    := 'Preparando backup... (aguarde)';
  Synchronize(@StartAnime);
  MyBd := Application.Location + 'sabik_plus.fdb';
  MyFilenameBackup := FormatDateTime('yyyymmddhhnnss', Now)+'.fbk';
  MyBackup := Application.Location + MyFilenameBackup;
  with TFBAdmin.Create(nil) do
    begin
      try
        try
          Host := 'localhost';
          Password := 'masterkey';
          Port := 3050;
          User := 'SYSDBA';
          Protocol := IBSPTCPIP;
          if Connect then
            Backup(MyBd, MyBackup, []);
        except;
          FMsg := 'Falha ao realizar o Backup!';
          Synchronize(@StartAnime);
          raise;
          Abort;
        end;
      finally
        Free;
      end;
    end;
    FMsg := 'Backup criado... (Aguarde)';
    Synchronize(@StartAnime);

    {=== aguarda a gravação do arquivo no disco ===}
    Sleep(3000);

    {=== Compacta ===}
    Command := TProcess.Create(nil);
    Command.CurrentDirectory := Application.Location;
    Command.Options := Command.Options + [poWaitOnExit, poNoConsole];
    Command.{%H-}CommandLine := 'xz -f '+MyFilenameBackup;
    if FileExists(MyBackup) then
    begin
      try
        Command.Execute;
      finally
        Command.Free;
      end;
    end;

    FMsg := 'Backup compactado... (aguarde)';
    Synchronize(@StartAnime);

    {=== Sobe o backup ===}
    Sleep(1000);

    FMsg := 'Enviando o backup a nuvem... (aguarde)';
    Synchronize(@StartAnime);

    if UploadBackups(MyBackup+'.xz') then
    begin
      Backup := TInfo.Create;
      Backups := TMapInfos.Create(con, 'info');
      try
        Backup.Id := 1;
        Backups.Get(Backup);
        Backup.Ultimo_backup := Now;
        Backups.Modify(Backup);
        Backups.Apply;
      finally
        Backup.Free;
        Backups.Free;
      end;
      FMsg := 'Backup realizado com sucesso!';
      Synchronize(@StartAnime);
      Sleep(2000);
      FMsg := '';
      Synchronize(@StartAnime);
    end
    else
    begin
      FMsg := 'Houve falha ao realizar o backup';
      Synchronize(@StartAnime);
    end;
end;

constructor TThreadBackup.Create(CreateSuspended: boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

destructor TThreadBackup.Destroy;
begin
  inherited Destroy;
end;

{ TfrmMain }

procedure TfrmMain.btnUpdateClick(Sender: TObject);
begin
  IniciaAtualizacao;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  CodigoStatus: Integer;
  Mensagem: String;
begin
  dm.nfe.WebServices.StatusServico.Executar;

  CodigoStatus := dm.nfe.WebServices.StatusServico.cStat;
  case CodigoStatus of
    107: // serviço em operação
    begin
      Mensagem := Trim(
        Format('Código:%d'#13'Mensagem: %s'#13'Tempo médio: %d segundo(s)', [
          dm.nfe.WebServices.StatusServico.cStat,
          dm.nfe.WebServices.StatusServico.xMotivo,
          dm.nfe.WebServices.StatusServico.TMed
        ])
      );

        MessageDlg(Mensagem, mtInformation, [mbOK], 0);
      end;

    108, 109: // serviço paralisado temporariamente (108) ou sem previsão (109)
      begin
        Mensagem := Trim(
          Format('Código:%d'#13'Motivo: %s'#13'%s', [
            dm.nfe.WebServices.StatusServico.cStat,
            dm.nfe.WebServices.StatusServico.xMotivo,
            dm.nfe.WebServices.StatusServico.xObs
          ])
        );

        MessageDlg(Mensagem, mtError, [mbOK], 0);
      end;
  else
    // qualquer outro retorno
    if CodigoStatus > 0 then
    begin
      Mensagem := Trim(
        Format('Webservice indisponível:'#13'Código:%d'#13'Motivo: %s'#13'%s', [
          dm.nfe.WebServices.StatusServico.cStat,
          dm.nfe.WebServices.StatusServico.xMotivo,
          dm.nfe.WebServices.StatusServico.xObs
        ])
      );
    end
    else
    begin
      Mensagem := 'Webservice indisponível e retorno em branco, tente novamente!';
    end;

    MessageDlg(Mensagem, mtInformation, [mbOK], 0);
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  tdi.Align := alClient;
  SetMenu(Handle, 0);
  sb.Panels.Items[1].Width := Self.Width - (512);
  {$IFDEF Desenvolvimento}
     lbDev.Visible := True;
  {$ELSE}
     lbDev.Visible := False;
  {$ENDIF}
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //if (Key = 27) then Close;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  sb.Panels[2].Text := up.GetCurrentVersion;
  Self.WindowState  := wsMaximized;
  timerUp.Enabled   := True;
  TimerNFCe.Enabled := True;
end;

procedure TfrmMain.mnClienteClick(Sender: TObject);
begin
  acClientes.Execute;
end;

procedure TfrmMain.sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
const
  ColorBack: Array[0..2] of TColor=($00F2FFF2, clWhite, clBtnFace);
  ColorFont: Array[0..2] of TColor=(clGreen, clRed, clDefault);
begin
  if ((Panel.Index in [0,1]) and (Panel.Text <> '')) then
  begin
    StatusBar.Canvas.Brush.Color := ColorBack[Panel.Index];
    StatusBar.Canvas.Font.Color  := ColorFont[Panel.Index];
    StatusBar.Canvas.Font.Bold   := True;
    StatusBar.Canvas.FillRect(Rect);
    StatusBar.Canvas.TextRect(Rect, ifthen(Panel.Index = 0, 5, Rect.Right - (Canvas.TextWidth(Panel.Text) + 80)), 2, Panel.Text);
  end;
end;

procedure TfrmMain.timerBackupTimer(Sender: TObject);
begin
  timerBackup.Enabled := False;
  VerificaBackup;
end;

procedure TfrmMain.TimerNFCeTimer(Sender: TObject);
var
  EnviaNFCe: TThreadEnviaNFCe;
begin
  //TimerNFCe.Enabled := False;
  {=== Verifica se há NFCe aguardando envio ===}
  EnviaNFCe := TThreadEnviaNFCe.Create();
  EnviaNFCe.Start;
end;

procedure TfrmMain.timerUpTimer(Sender: TObject);
begin
  timerUp.Enabled := False;
  VerificaAtualizacao;
  timerBackup.Enabled := True;
end;

procedure TfrmMain.upDownloadProgress(Sender: TObject; Percent: Integer);
begin
  pbar.Position := Percent;
  pbar.Update;
  sb.Panels[0].Text := 'Atualizando... ('+Percent.to_s+'%)';
  Application.ProcessMessages;
end;

procedure TfrmMain.IniciaAtualizacao;
begin
  sb.Tag := 0;
  sb.Panels[0].Text := 'Preparando...';
  btnUpdate.Visible := False;
  btnNotUpdate.Visible := False;
  pbar.Visible := True;
  up.Execute(True);
end;

procedure TfrmMain.VerificaAtualizacao;
var
  Info: IGetInfo;
begin
  Info := TGetInfo.new;
  up.HTTPParams.Clear;
  up.HTTPParams.Add('app=7');
  up.HTTPParams.Add('id='+Info.id_gateway.to_s);
  up.HTTPParams.Add('token='+Info.token);
  if up.Check then
  begin
    sb.Panels[0].Text := 'Há uma nova versão ('+ up.GetVersionUpdate+
                         ') disponivel! Gostaria de atualizar agora?';
    btnUpdate.Visible    := True;
    btnNotUpdate.Visible := True;
  end
end;

procedure TfrmMain.VerificaBackup;
var
  VHoras: Integer;
begin
  {=== Verifica se o útimo backup foi realizado a aproximadamente 48 h ===}
  VHoras := round((Now - TGetInfo.new.ultimo_backup)*24);
  if  VHoras > 47 then
  begin
    sb.Panels[1].Text := 'O último backup foi há ' + VHoras.to_s + ' horas ' +
                         'Clique  no botão ao lado para fazer um novo backup';
    btnGoBackup.Visible := True;
  end;
end;

function TfrmMain.IsShortcut(var Message: TLMKey): boolean;
begin
  {$IFDEF MSWINDOWS}
    if Message.CharCode = VK_MENU then
    begin
      if GetMenu(Handle) = 0 then
        SetMenu(Handle, Menu.Handle)
      else
        SetMenu(Handle, 0);
      Exit(True);
    end;
  {$ENDIF}
  Result := inherited IsShortcut(Message);
end;

procedure TfrmMain.acVendasExecute(Sender: TObject);
begin
  if not Assigned(frmVendas) then
     frmVendas := TfrmVendas.Create(Self);
   tdi.ShowFormInPage(frmVendas, 5);
end;

procedure TfrmMain.btnGoBackupClick(Sender: TObject);
begin
  acFazerBackup.Execute;
end;

procedure TfrmMain.btnNotUpdateClick(Sender: TObject);
begin
  try
    btnUpdate.Visible := False;
    sb.Tag := 0;
    sb.Panels[0].Text := '';
  finally
    btnNotUpdate.Visible := False;
  end;
end;

procedure TfrmMain.acEntradasExecute(Sender: TObject);
begin
  if not Assigned(frmEntradas) then
     frmEntradas := TfrmEntradas.Create(Self);
   tdi.ShowFormInPage(frmEntradas, 8);
end;

procedure TfrmMain.acFazerBackupExecute(Sender: TObject);
var
  Backup: TThreadBackup;
begin
  btnGoBackup.Visible := False;
  Backup := TThreadBackup.Create();
  Backup.Start;
end;

procedure TfrmMain.acFornecedoresExecute(Sender: TObject);
begin
  if not Assigned(frmFornecedores) then
    frmFornecedores := TfrmFornecedores.Create(Self);
  tdi.ShowFormInPage(frmFornecedores, 3);
end;

procedure TfrmMain.acGruposExecute(Sender: TObject);
begin
  if not Assigned(frmGrupos) then
    frmGrupos := TfrmGrupos.Create(Self);
  tdi.ShowFormInPage(frmGrupos, 2);
end;

procedure TfrmMain.acNFCeExecute(Sender: TObject);
begin
  if not Assigned(frmDFs) then
    frmDFs := TfrmDFs.Create(Self);
  tdi.ShowFormInPage(frmDFs, 17);
end;

procedure TfrmMain.acProdutosExecute(Sender: TObject);
begin
  if not Assigned(frmProdutos) then
    frmProdutos := TfrmProdutos.Create(Self);
  tdi.ShowFormInPage(frmProdutos, 1);
end;

procedure TfrmMain.acClientesExecute(Sender: TObject);
begin
  if not Assigned(frmClientes) then
     frmClientes := TfrmClientes.Create(Self);
   tdi.ShowFormInPage(frmClientes, 0);
end;

procedure TfrmMain.acConfiguracoesExecute(Sender: TObject);
begin
  if not Assigned(frmConfig) then
    frmConfig := TfrmConfig.Create(Self);
  tdi.ShowFormInPage(frmConfig, 15);
end;

procedure TfrmMain.acBalancoExecute(Sender: TObject);
begin
  //if not Assigned(frmDFs) then
  //    frmDFs := TfrmDFs.Create(Self);
  //  tdi.ShowFormInPage(frmDFs, 17);
end;

procedure TfrmMain.acCaixaExecute(Sender: TObject);
begin
  if not Assigned(frmCaixa) then
    frmCaixa := TfrmCaixa.Create(Self);
  tdi.ShowFormInPage(frmCaixa, 16);
end;

procedure TfrmMain.acRelatoriosExecute(Sender: TObject);
begin
  if not Assigned(frmRelatorios) then
    frmRelatorios := TfrmRelatorios.Create(Self);
  tdi.ShowFormInPage(frmRelatorios, 14);
end;

procedure TfrmMain.acUsuariosExecute(Sender: TObject);
begin
  if not Assigned(frmUsuarios) then
    frmUsuarios := TfrmUsuarios.Create(Self);
  tdi.ShowFormInPage(frmUsuarios, 4);
end;

end.
