unit u_relatorios;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LR_Class, LR_DBSet, LR_View, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, ComCtrls, StdCtrls, Buttons, EditBtn, Spin,
  ACBrSintegra, dSQLdbBroker, dUtils, dateutils, u_dm, u_models, u_libs;

type

  { TfrmRelatorios }

  TfrmRelatorios = class(TForm)
    btnFechar: TBitBtn;
    btnGerar: TBitBtn;
    btnExportar: TBitBtn;
    cbMes: TComboBox;
    deEstoque: TDateEdit;
    pnControles: TPanel;
    preview: TfrPreview;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    pnClient: TPanel;
    pgReports: TPageControl;
    pnDate: TPanel;
    pnEstoque: TPanel;
    pnFinanceiros: TPanel;
    rgEstoque: TRadioGroup;
    saveReport: TSaveDialog;
    seAno: TSpinEdit;
    StatusBar1: TStatusBar;
    tabEstoque: TTabSheet;
    tabFiscal: TTabSheet;
    procedure btGerarClick(Sender: TObject);
    procedure btGerarFinanceiroClick(Sender: TObject);
    procedure btnExportarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnGerarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure rgEstoqueSelectionChanged(Sender: TObject);
  private
    procedure GerarMapaMensalDeNFCe;
    procedure GerarRelatoriosDeEstoque;
    procedure GerarSintegra;
    function GerarRegistro10e11(ASintegra: TACBrSintegra): String;
    procedure GerarRegistro74(ASintegra: TACBrSintegra);
    procedure GerarRegistro75(ASintegra: TACBrSintegra);
  public
    { public declarations }
  end;

var
  frmRelatorios: TfrmRelatorios;

implementation

{$R *.lfm}

{ TfrmRelatorios }

procedure TfrmRelatorios.btGerarClick(Sender: TObject);
begin
  GerarRelatoriosDeEstoque;
end;

procedure TfrmRelatorios.btGerarFinanceiroClick(Sender: TObject);
begin
  GerarMapaMensalDeNFCe;
end;

procedure TfrmRelatorios.btnExportarClick(Sender: TObject);
begin
  if saveReport.Execute then
    preview.ExportTo(saveReport.FileName);
end;

procedure TfrmRelatorios.btnFecharClick(Sender: TObject);
begin
  preview.Clear;
end;

procedure TfrmRelatorios.btnGerarClick(Sender: TObject);
begin
  case pgReports.ActivePageIndex of
    0: GerarRelatoriosDeEstoque;
    1: GerarMapaMensalDeNFCe;
  end;
end;

procedure TfrmRelatorios.FormCreate(Sender: TObject);
begin
  dm.db.Connected := False;
  dm.db.Connected := True;
end;

procedure TfrmRelatorios.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   {=== Esc ===}
  if (Key=27) then Close;
end;

procedure TfrmRelatorios.FormShow(Sender: TObject);
begin
  cbMes.ItemIndex := MonthOf(Date) - 1;
  seAno.Value     := YearOf(Date);
  deEstoque.Date := Date - 3;
  Self.SetFocus;
end;

procedure TfrmRelatorios.rgEstoqueSelectionChanged(Sender: TObject);
begin
  pnDate.Visible := rgEstoque.ItemIndex = 0;
end;

procedure TfrmRelatorios.GerarMapaMensalDeNFCe;
var
  VFim: TDateTime;
  VIni: TDateTime;
begin
  VIni := GetFirstDayMonth(cbMes.ItemIndex + 1, seAno.Value);
  VFim := GetLastDayMonth(cbMes.ItemIndex + 1, seAno.Value);
  dm.MapaMensal.ParamByName('pIni').AsDate := VIni;
  dm.MapaMensal.ParamByName('pFim').AsDate := VFim;
  dm.rptMapaMensal.ShowReport;
end;

procedure TfrmRelatorios.GerarRelatoriosDeEstoque;
begin
  case rgEstoque.ItemIndex of
    0: begin
      dm.Estoque.ParamByName('pDate').AsDate := deEstoque.Date;
      dm.rptLivroEstoque.ShowReport;
    end;
    1: dm.rptReposicao.ShowReport;
    2: dm.rptZerados.ShowReport;
    3: dm.rptInventario.ShowReport;
  end
end;

procedure TfrmRelatorios.GerarSintegra;
var
  Sintegra: TACBrSintegra;
  FileSintegra: String;
begin
  Sintegra := TACBrSintegra.Create(Self);
  try
    FileSintegra :=  GerarRegistro10e11(Sintegra);
    GerarRegistro74(Sintegra);
    GerarRegistro75(Sintegra);
    Sintegra.FileName := Application.Location + 'relatorios' + PathDelim + FileSintegra + '.txt';
    Sintegra.GeraArquivo;
  finally
    Sintegra.Free;
    ShowMessage('Relatório gerado com sucesso!');
  end;
end;

function TfrmRelatorios.GerarRegistro10e11(ASintegra: TACBrSintegra): String;
var
  Empresa: TEmpresa;
  Empresas: TMapEmpresas;
label
  liberar;
begin
  Result := '';
  Empresa := TEmpresa.Create;
  Empresas := TMapEmpresas.Create(con, 'empresa');
  try
    Empresa.Id := 1;
    if not Empresas.Get(Empresa) then goto liberar;

    with ASintegra.Registro10 do
    begin
      CNPJ := Empresa.CNPJ;
      Inscricao := Empresa.Insc;
      RazaoSocial := Empresa.Razao;
      Cidade := Empresa.Cidade;
      Estado := Empresa.Uf;
      DataInicial := GetFirstDayMonth(12, 2016);
      DataFinal := GetLastDayMonth(12, 2016);
      CodigoConvenio := '3';
      NaturezaInformacoes := '3';
      FinalidadeArquivo := '1';
    end;
    with ASintegra.Registro11 do
    begin
      Endereco             := Empresa.Endereco;
      Numero               := Empresa.Numero.to_s;
      Complemento          := Empresa.Complemento;
      Bairro               := Empresa.Bairro;
      Cep                  := Empresa.Cep;
      Responsavel          := Empresa.Responsavel;
      Telefone             := Empresa.Telefone;
    end;
    Result := Empresa.Fantasia+'_sintegra_2016';
    liberar:
  finally
    Empresa.Free;
    Empresas.Free;
  end;
end;

procedure TfrmRelatorios.GerarRegistro74(ASintegra: TACBrSintegra);
var
  Produto: TProduto;
  qry: TdSQLdbQuery;
  Sintegra74: TRegistro74;
begin
  Produto := TProduto.Create;
  qry := TdSQLdbQuery.Create(con);
  try
    qry.SQL.Text := 'select id, estoque, preco_compra from produtos where estoque > 0';
    qry.Open;
    qry.First;
    while not qry.EOF do
    begin
      dGetFields(Produto, qry.Fields);
      Sintegra74 := TRegistro74.Create;
      Sintegra74.Data := GetLastDayMonth(12, 2016);
      Sintegra74.Codigo := Format('%.13d', [Produto.Id]);
      Sintegra74.CodigoPosse := '1';
      Sintegra74.Quantidade := Produto.Estoque;
      Sintegra74.ValorProduto := (Produto.Preco_compra * Produto.Estoque);
      ASintegra.Registros74.Add(Sintegra74);
      qry.Next;
    end;
  finally
    qry.Free;
    Produto.Free;
  end;
end;

procedure TfrmRelatorios.GerarRegistro75(ASintegra: TACBrSintegra);
var
  Produto: TProduto;
  qry: TdSQLdbQuery;
  Sintegra75: TRegistro75;
begin
  Produto := TProduto.Create;
  qry := TdSQLdbQuery.Create(con);
  try
    qry.SQL.Text := 'select id, ncm, descricao, unidade, tributacao, aliquota '+
                    'from produtos where estoque > 0';
    qry.Open;
    qry.First;
    while not qry.EOF do
    begin
      dGetFields(Produto, qry.Fields);
      Sintegra75 := TRegistro75.Create;
      Sintegra75.DataInicial := GetFirstDayMonth(12, 2016);
      Sintegra75.DataFinal := GetLastDayMonth(12, 2016);
      Sintegra75.Codigo := Format('%.13d', [Produto.Id]);
      if Trim(Produto.Ncm) <> '' then
        Sintegra75.NCM := Produto.Ncm;
      Sintegra75.Descricao := Trim(Produto.Descricao.raw);
      Sintegra75.Unidade := Trim(Produto.Unidade);
      if UpperCase(Trim(Produto.Tributacao)) = 'T' then
        Sintegra75.AliquotaICMS := 17
      else
        Sintegra75.AliquotaICMS := 0;
      ASintegra.Registros75.Add(Sintegra75);
      qry.Next;
    end;
  finally
    qry.Free;
    Produto.Free;
  end;
end;

end.

