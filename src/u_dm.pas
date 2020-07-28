unit u_dm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Translations, Dialogs, ACBrNFe, ACBrPosPrinter,
  ACBrNFeDANFeESCPOS, ACBrDANFCeFortesFr, dSQLdbBroker, LR_Class, LR_DBSet,
  lr_e_pdf, LRDialogControls, ghSQL, ghSQLdbLib, IBConnection, sqldb, db,
  u_rules, u_libs, u_models, VersionSupport, pcnConversao, LR_DSet, LR_RRect;

type

  { Tdm }

  Tdm = class(TDataModule)
    dtsLivroEstoque: TfrDBDataSet;
    dtsMapaMensal: TfrDBDataSet;
    round: TfrRoundRectObject;
    MapaMensal: TSQLQuery;
    EstoqueDATA_EMISSAO: TDateField;
    EstoqueDATA_ENTRADA: TDateField;
    EstoqueDESCRICAO: TStringField;
    EstoqueESTOQUE: TBCDField;
    EstoqueNF: TStringField;
    EstoqueNOME: TStringField;
    EstoquePRODUTO: TLongintField;
    EstoqueQUANTIDADE: TBCDField;
    EstoqueRAZAO: TStringField;
    EstoqueREFERENCIA: TStringField;
    EstoqueSEQUENCIA: TLongintField;
    EstoqueSUBTOTAL: TBCDField;
    fortes: TACBrNFeDANFCeFortes;
    MapaMensalDEMIS: TDateField;
    MapaMensalDESCONTOS: TBCDField;
    MapaMensalNFCE_FIM: TLongintField;
    MapaMensalNFCE_INI: TLongintField;
    MapaMensalQTD: TLongintField;
    MapaMensalSOMA: TBCDField;
    posPrinter: TACBrPosPrinter;
    escpos: TACBrNFeDANFeESCPOS;
    nfe: TACBrNFe;
    db: TIBConnection;
    dtsZerados: TfrDBDataSet;
    dtsReposicao: TfrDBDataSet;
    dtsInventario: TfrDBDataSet;
    InventarioDESCRICAO: TStringField;
    InventarioDESCRICAO1: TStringField;
    InventarioESTOQUE: TBCDField;
    InventarioESTOQUE1: TBCDField;
    InventarioID: TLongintField;
    InventarioID1: TLongintField;
    InventarioPRECO_COMPRA: TBCDField;
    InventarioPRECO_COMPRA1: TBCDField;
    InventarioPRECO_VENDA: TBCDField;
    InventarioPRECO_VENDA1: TBCDField;
    pdf: TfrTNPDFExport;
    Reposicao: TSQLQuery;
    Inventario: TSQLQuery;
    Estoque: TSQLQuery;
    rptLivroEstoque: TfrReport;
    rptMapaMensal: TfrReport;
    Zerados: TSQLQuery;
    ReposicaoDESCRICAO: TStringField;
    ReposicaoDESCRICAO1: TStringField;
    ReposicaoEAN13: TStringField;
    ReposicaoEAN14: TStringField;
    ReposicaoESTOQUE: TBCDField;
    ReposicaoESTOQUE1: TBCDField;
    ReposicaoESTOQUE_MIN: TBCDField;
    ReposicaoESTOQUE_MIN1: TBCDField;
    ReposicaoID: TLongintField;
    ReposicaoID1: TLongintField;
    ReposicaoPRECO_VENDA: TBCDField;
    ReposicaoPRECO_VENDA1: TBCDField;
    rptInventario: TfrReport;
    rptReposicao: TfrReport;
    rptZerados: TfrReport;
    sqlt: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure VerifyUpdateBD;
    procedure UpdateBD(AVersaoBD: String);
    procedure UpdateVersionBD;
    procedure ConfiguraNfe;
  public
    procedure GetConfigs;
  end;

var
   dm: Tdm;
  Co: TghSQLConnector;

implementation

{$R *.lfm}

{ Tdm }

procedure Tdm.DataModuleCreate(Sender: TObject);
var
  VAppPath: RawByteString;
begin
  VAppPath := ExtractFilePath(ParamStr(0)) + PathDelim;

  if not DirectoryExists(VAppPath+'relatorios') then
    ForceDirectories(VAppPath+'relatorios');
  if not DirectoryExists(VAppPath+'logs') then
    {%H-}ForceDirectories(VAppPath+'logs');

  Co := TghSQLConnector.Create(TghFirebirdLib);
  try
    Co.User := 'SYSDBA';
    Co.Password := 'masterkey';
    //Co.Host := '127.0.0.1';
    Co.Database := VAppPath + 'sabik_plus.fdb';
    Co.Connect;
  except
    raise Exception.Create('GH NÃ£o foi possível se conectar ao Banco de Dados');
  end;

  try
    db.Connected := False;
    db.DatabaseName := VAppPath + 'sabik_plus.fdb';;
    db.Connected := True;
  except
    raise Exception.Create('Não foi possível se conectar ao Banco de Dados');
  end;

  VerifyUpdateBD;

  ConfiguraNfe;
  GetConfigs;

  TranslateUnitResourceStrings('lr_const', VAppPath + 'lr_const.pt_BR.po', 'pt_BR', '');
end;

procedure Tdm.DataModuleDestroy(Sender: TObject);
begin
  Co.Free;
end;

procedure Tdm.VerifyUpdateBD;
begin
    if VerifyNeedUpdateBD(TGetInfo.new.versao_bd, GetFileVersion) then
       UpdateBD(TGetInfo.new.versao_bd);
end;

{$i scripts_update.inc}

procedure Tdm.UpdateVersionBD;
var
  Info: TInfo;
  Infos: TMapInfos;
begin
  Info := TInfo.Create;
  Infos := TMapInfos.Create(con, 'info');
  try
    Info.Id := 1;
    Infos.Get(Info);
    Info.Versao_bd := GetFileVersion;
    Infos.Modify(Info);
    Infos.Apply;
  finally
    Info.Free;
    Infos.Free;
  end;
end;

procedure Tdm.ConfiguraNfe;
var
  PathApp, PathArqNFe, PathPDF, PathArquivos, PathTmp, PathSchemas: string;
begin
  PathApp      := ExtractFilePath(ParamStr(0)) + PathDelim;
  PathSchemas  := PathApp + 'schemas' + PathDelim;
  PathArqNFe   := PathApp + 'documentos' + PathDelim;
  PathPDF      := PathArqNFe + 'pdf' + PathDelim;
  PathArquivos := PathArqNFe + 'arquivos' + PathDelim;
  PathTmp      := PathArqNFe + 'tmp' + PathDelim;

  if not DirectoryExists(PathPDF) then
    ForceDirectories(PathPDF);

  if not DirectoryExists(PathArquivos) then
    ForceDirectories(PathArquivos);

  if not DirectoryExists(PathTmp) then
    ForceDirectories(PathTmp);

  // configuração do ACBRNFE
  //nfe.Configuracoes.Arquivos.IniServicos                := PathApp +PathDelim + 'ACBrNFeServicos.ini';
  nfe.Configuracoes.Arquivos.AdicionarLiteral           := True;           // adiciona o literal NFe ao nome do arquivo
  nfe.Configuracoes.Arquivos.EmissaoPathNFe             := True;           //
  nfe.Configuracoes.Arquivos.Salvar                     := True;           // salva os xml nos diretorios configurados
  nfe.Configuracoes.Arquivos.SalvarApenasNFeProcessadas := False;          // Se True salva somente as NF-es processadas e autorizadas/denegadas
  nfe.Configuracoes.Arquivos.SepararPorMes              := True;           // cria um diretorio para o mes
  nfe.Configuracoes.Arquivos.SepararPorCNPJ             := True;           // cria um diretorio para o cnpj do emitente
  nfe.Configuracoes.Arquivos.SepararPorModelo           := False;           // cria um diretorio por modelo de nota (65/55)
  nfe.Configuracoes.Arquivos.PathSalvar                 := PathArquivos;   // diretório raiz da NFe
  nfe.Configuracoes.Arquivos.PathNFe                    := PathArquivos;   // diretorio onde serão gravadas as NFes emitidas
  nfe.Configuracoes.Arquivos.PathInu                    := PathArquivos;   // diretorio onde serão gravadas as inutilizações
  nfe.Configuracoes.Arquivos.PathEvento                 := PathArquivos;   // diretorio onde serão gravados os eventos
  nfe.Configuracoes.Arquivos.PathSchemas                := PathSchemas;    // diretorio onde estão os schemas da NFe
end;

procedure Tdm.GetConfigs;
var
  Configuracao: TConfiguracao;
  Configuracoes: TMapConfiguracoes;
  ok: boolean;
begin
  Configuracao  := TConfiguracao.Create;
  Configuracoes := TMapConfiguracoes.Create(con, 'configuracoes');
  try
    Configuracao.Id := 1;
    Configuracoes.Get(Configuracao);
    nfe.Configuracoes.Certificados.ArquivoPFX  := Configuracao.Path_certificado;
    nfe.Configuracoes.Certificados.Senha       := Decifra(16, '1046', Configuracao.Senha_certificado);
    nfe.Configuracoes.Certificados.NumeroSerie := Configuracao.Serie_certificado;
    nfe.Configuracoes.WebServices.Ambiente     := StrToTpAmb(ok, Configuracao.Ambiente.to_s);
    nfe.Configuracoes.Geral.IdCSC              := Configuracao.Id_csc.to_s;
    nfe.Configuracoes.Geral.CSC                := Decifra(16, '1046' , Configuracao.Token_csc);
    nfe.Configuracoes.WebServices.TimeOut      := Configuracao.TimeOut;
    posPrinter.CortaPapel                      := Configuracao.Corta_papel = 1;
    if Configuracao.Porta <> '' then
      posPrinter.Porta                         := Configuracao.Porta;
    if Configuracao.Velocidade <> '' then
      posPrinter.Device.Baud                   := Configuracao.Velocidade.to_i;
    posPrinter.Modelo                          := TACBrPosPrinterModelo(Configuracao.Modelo_impressora);
  finally
    Configuracao.Free;
    Configuracoes.Free;
  end;
end;

end.

