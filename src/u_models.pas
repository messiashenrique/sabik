unit u_models;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dSQLdbBroker, IBConnection;

Const
  ArrayTrib: Array[0..3] of String = ('T', 'I', 'N', 'F');

type

  { TCaixa }
  TCaixa = Class(TObject)
  private
    FConta_paga: Integer;
    FData_cadastro: TDateTime;
    FData_lancamento: TDateTime;
    FDescricao: String;
    FId: Integer;
    FPagamento: Integer;
    FParcela: Integer;
    FPedido: Integer;
    FProjecao: Integer;
    FStatus: String;
    FTipo: String;
    FValor: Currency;
  published
    property Conta_paga: Integer read FConta_paga write FConta_paga;
    property Data_cadastro: TDateTime read FData_cadastro write FData_cadastro;
    property Data_lancamento: TDateTime read FData_lancamento write FData_lancamento;
    property Descricao: String read FDescricao write FDescricao;
    property Id: Integer read FId write FId;
    property Pagamento: Integer read FPagamento write FPagamento;
    property Parcela: Integer read FParcela write FParcela;
    property Pedido: Integer read FPedido write FPedido;
    property Projecao: Integer read FProjecao write FProjecao;
    property Status: String read FStatus write FStatus;
    property Tipo: String read FTipo write FTipo;
    property Valor: Currency read FValor write FValor;
  end;

  { TCliente }
  TCliente = Class(TObject)
  private
    FAniversario: TDateTime;
    FBairro: String;
    FCelular_1: String;
    FCelular_2: String;
    FCep: String;
    FCidade: String;
    FCpf_cnpj: String;
    FData_cad: TDateTime;
    FEmail: String;
    FEndereco: String;
    FId: Integer;
    FNome: String;
    FObservacao: String;
    FRazao: String;
    FRg_ie: String;
    FTelefone_1: String;
    FTelefone_2: String;
    FTipo: String;
    FUf: String;
  published
    property Aniversario : TDateTime Read FAniversario Write FAniversario;
    property Bairro : String Read FBairro Write FBairro;
    property Celular_1 : String Read FCelular_1 Write FCelular_1;
    property Celular_2 : String Read FCelular_2 Write FCelular_2;
    property Cep : String Read FCep Write FCep;
    property Cidade : String Read FCidade Write FCidade;
    property Cpf_cnpj : String Read FCpf_cnpj Write FCpf_cnpj;
    property Data_cad : TDateTime Read FData_cad Write FData_cad;
    property Email : String Read FEmail Write FEmail;
    property Endereco : String Read FEndereco Write FEndereco;
    property Id : Integer Read FId Write FId;
    property Nome : String Read FNome Write FNome;
    property Observacao : String Read FObservacao Write FObservacao;
    property Razao : String Read FRazao Write FRazao;
    property Rg_ie : String Read FRg_ie Write FRg_ie;
    property Telefone_1 : String Read FTelefone_1 Write FTelefone_1;
    property Telefone_2 : String Read FTelefone_2 Write FTelefone_2;
    property Tipo : String Read FTipo Write FTipo;
    property Uf : String Read FUf Write FUf;
  end;

  { TConfiguracao }

  TConfiguracao = Class(TObject)
  private
    FAbre_gaveta: integer;
    FAmbiente: integer;
    FCorta_papel: integer;
    FGrupo_padrao: integer;
    FId: integer;
    FId_csc: integer;
    FItens_uma_linha: integer;
    FMargem_a_prazo: Currency;
    FMargem_a_vista: Currency;
    FModelo_impressora: integer;
    FPath_certificado: string;
    FPorta: string;
    FSenha_certificado: string;
    FSerie_certificado: string;
    FTimeOut: Integer;
    FToken_csc: string;
    FVelocidade: string;
  published
    property Id: integer read FId write FId;
    property Modelo_impressora: Integer read FModelo_impressora write FModelo_impressora;
    property TimeOut: Integer read FTimeOut write FTimeOut;
    property Porta: string read FPorta write FPorta;
    property Velocidade: string read FVelocidade write FVelocidade;
    property Abre_gaveta: integer read FAbre_gaveta write FAbre_gaveta;
    property Itens_uma_linha: integer read FItens_uma_linha write FItens_uma_linha;
    property Corta_papel: integer read FCorta_papel write FCorta_papel;
    property Ambiente: integer read FAmbiente write FAmbiente;
    property Id_csc: integer read FId_csc write FId_csc;
    property Token_csc: string read FToken_csc write FToken_csc;
    property Serie_certificado: string read FSerie_certificado write FSerie_certificado;
    property Path_certificado: string read FPath_certificado write FPath_certificado;
    property Senha_certificado: string read FSenha_certificado write FSenha_certificado;
    property Margem_a_vista: Currency read FMargem_a_vista write FMargem_a_vista;
    property Margem_a_prazo: Currency read FMargem_a_prazo write FMargem_a_prazo;
    property Grupo_padrao: integer read FGrupo_padrao write FGrupo_padrao;
  end;

  { TDocumentoFiscal }

  TDocumentoFiscal = class(Tobject)
  private
    FchNFe: string;
    FcStat: integer;
    FdhEmis: TDateTime;
    FdhRecbto: TDateTime;
    FfinNFe: integer;
    FId: integer;
    FModelo: string;
    FnProt: string;
    FPath_xml: string;
    FPedido: integer;
    FSerie: integer;
    FtpAmb: integer;
    FtpEmis: integer;
    FValor: Currency;
    FxMotivo: string;
  published
    property Id: integer read FId write FId;
    property Pedido: integer read FPedido write FPedido;
    property tpAmb: integer read FtpAmb write FtpAmb;
    property Modelo: string read FModelo write FModelo;
    property tpEmis: integer read FtpEmis write FtpEmis;
    property finNFe: integer read FfinNFe write FfinNFe;
    property Serie: integer read FSerie write FSerie;
    property dhEmis: TDateTime read FdhEmis write FdhEmis;
    property dhRecbto: TDateTime read FdhRecbto write FdhRecbto;
    property nProt: string read FnProt write FnProt;
    property chNFe: string read FchNFe write FchNFe;
    property xMotivo: string read FxMotivo write FxMotivo;
    property cStat: integer read FcStat write FcStat;
    property Valor: Currency read FValor write FValor;
    property Path_xml: string read FPath_xml write FPath_xml;
  end;

  { TEmpresa }

  TEmpresa = Class(TObject)
  private
    FAbertura: TDateTime;
    FBairro: string;
    FCep: string;
    FCidade: string;
    FCnae_1: string;
    FCnae_2: string;
    FCnpj: string;
    FComplemento: string;
    FCpf_responsavel: string;
    FEmail: string;
    FEndereco: string;
    FFantasia: string;
    FFax: string;
    FId: integer;
    FInsc: string;
    FNatureza_juridica: string;
    FNumero: integer;
    FObservacao: string;
    FRazao: string;
    FResponsavel: string;
    FSituacao: string;
    FTelefone: string;
    FTipo_empresa: string;
    FUf: string;
  published
    property Abertura: TDateTime Read FAbertura Write FAbertura;
    property Bairro: string Read FBairro Write FBairro;
    property Cep: string Read FCep Write FCEP;
    property Cidade: string Read FCidade Write FCidade;
    property Cnae_1: string Read FCnae_1 Write FCnae_1;
    property Cnae_2: string Read FCnae_2 Write FCnae_2;
    property Cnpj: string Read FCnpj Write FCnpj;
    property Complemento: string Read FComplemento Write FComplemento;
    property Cpf_responsavel: string Read FCpf_responsavel Write FCpf_responsavel;
    property Email: string read FEmail write FEmail;
    property Endereco: string read FEndereco write FEndereco;
    property Fantasia: string read FFantasia write FFantasia;
    property Fax: string read FFax write FFax;
    property Id: integer read FId write FId;
    property Insc : string read FInsc write FInsc;
    property Natureza_juridica: string read FNatureza_juridica write FNatureza_juridica;
    property Numero: integer read FNumero write FNumero;
    property Observacao: string read FObservacao write FObservacao;
    property Razao: string read FRazao write FRazao;
    property Responsavel: string read FResponsavel write FResponsavel;
    property Situacao: string read FSituacao write FSituacao;
    property Telefone: string read FTelefone write FTelefone;
    property Tipo_empresa: string read FTipo_empresa write FTipo_empresa;
    property Uf: string read FUf write FUf;
  end;

  { TEntrada }

  TEntrada = Class(TObject)
  private
    FAcrescimo: Currency;
    FChave_nfe: String;
    FData_emissao: TDateTime;
    FData_entrada: TDateTime;
    FDesconto: Currency;
    FFornecedor: Integer;
    FFrete: Currency;
    FId: Integer;
    FNf: String;
    FObservacao: String;
    FSubtotal: Currency;
    FUsuario: Integer;
  published
    property Acrescimo: Currency Read FAcrescimo Write FAcrescimo;
    property Chave_nfe: String Read FChave_nfe Write FChave_nfe;
    property Data_emissao: TDateTime Read FData_emissao Write FData_emissao;
    property Data_entrada: TDateTime Read FData_entrada Write FData_entrada;
    property Desconto: Currency Read FDesconto Write FDesconto;
    property Fornecedor : Integer Read FFornecedor Write FFornecedor;
    property Frete: Currency Read FFrete Write FFrete;
    property Id: Integer Read FId Write FId;
    property Nf: String Read FNf Write FNf;
    property Observacao: String Read FObservacao Write FObservacao;
    property Subtotal: Currency Read FSubtotal Write FSubtotal;
    property Usuario: Integer Read FUsuario Write FUsuario;
  end;

  { TFormaPgto }
  TFormaPgto = Class(TObject)
  private
    FDescricao: String;
    FId: Integer;
    FPeriodo_lancamento: Integer;
    FTaxa: Currency;
  published
    property Descricao: String read FDescricao write FDescricao;
    property Id: Integer read FId write FId;
    property Periodo_lancamento : Integer read FPeriodo_lancamento write FPeriodo_lancamento;
    property Taxa: Currency read FTaxa write FTaxa;
  end;

  { TFornecedor }
  TFornecedor = Class(TObject)
  private
    FBairro : String;
    FCelular : String;
    FCep : String;
    FCidade : String;
    FCnpj : String;
    FData_cad : TDateTime;
    FEmail : String;
    FEndereco : String;
    FFax : String;
    FId : Longint;
    FIe : String;
    FNome : String;
    FObservacao : String;
    FRazao : String;
    FRepresentante : String;
    FTelefone : String;
    FUf : String;
  published
    property Bairro : String Read FBairro Write FBairro;
    property Celular : String Read FCelular Write FCelular;
    property Cep : String Read FCep Write FCep;
    property Cidade : String Read FCidade Write FCidade;
    property Cnpj : String Read FCnpj Write FCnpj;
    property Data_cad : TDateTime Read FData_cad Write FData_cad;
    property Email : String Read FEmail Write FEmail;
    property Endereco : String Read FEndereco Write FEndereco;
    property Fax : String Read FFax Write FFax;
    property Id : Longint Read FId Write FId;
    property Ie : String Read FIe Write FIe;
    property Nome : String Read FNome Write FNome;
    property Observacao : String Read FObservacao Write FObservacao;
    property Razao : String Read FRazao Write FRazao;
    property Representante : String Read FRepresentante Write FRepresentante;
    property Telefone : String Read FTelefone Write FTelefone;
    Property Uf : String Read FUf Write FUf;
  end;

  { TGrupo }
  TGrupo = Class(TObject)
  private
    FAliquota: Currency;
    FId: Integer;
    FNcm_padrao: String;
    FNome: String;
    FObservacao: String;
    FTributacao: String;
  published
    property Aliquota: Currency Read FAliquota Write FAliquota;
    property Id: Integer Read FId Write FId;
    property Ncm_padrao: String Read FNcm_padrao Write FNcm_padrao;
    property Nome: String Read FNome Write FNome;
    property Observacao: String Read FObservacao Write FObservacao;
    property Tributacao: String Read FTributacao Write FTributacao;
   end;


  { TInfo }
  TInfo = Class(TObject)
  private
    FGrupo_padrao: Integer;
    FId: Integer;
    FId_gateway: Integer;
    FToken: String;
    FUltimo_backup: TDateTime;
    FVersao_bd: String;
  published
    property Grupo_padrao: Integer Read FGrupo_padrao Write FGrupo_padrao;
    property Id: Integer Read FId Write FId;
    property Id_gateway: Integer Read FId_gateway Write FId_gateway;
    property Token: String Read FToken Write FToken;
    property Ultimo_backup: TDateTime Read FUltimo_backup Write FUltimo_backup;
    property Versao_bd: String read FVersao_bd write FVersao_bd;
  end;

  { TItensDF }

  TItensDF = Class(TObject)

  private
    FAcrescimo: Currency;
    FCest: string;
    FDesconto: Currency;
    FDescricao: string;
    FEan13: string;
    FId: integer;
    FNcm: string;
    FPedido: integer;
    FQuantidade: currency;
    FSequencia: integer;
    FTributacao: string;
    FUnidade: string;
    FValor: Currency;
  published
    property Sequencia: integer read FSequencia write FSequencia;
    property Quantidade: currency read FQuantidade write FQuantidade;
    property Valor: Currency read FValor write FValor;
    property Desconto: Currency read FDesconto write FDesconto;
    property Acrescimo: Currency read FAcrescimo write FAcrescimo;
    property Pedido: integer read FPedido write FPedido;
    property Id: integer read FId write FId;
    property Ncm: string read FNcm write FNcm;
    property Cest: string read FCest write FCest;
    property Ean13: string read FEan13 write FEan13;
    property Descricao: string read FDescricao write FDescricao;
    property Tributacao: string read FTributacao write FTributacao;
    property Unidade: string read FUnidade write FUnidade;
  end;

  { TItemEntrada }
  TItemEntrada = Class(TObject)
  private
    FAcrescimo: Currency;
    FDesconto: Currency;
    FEntrada: Integer;
    FPreco: Currency;
    FProduto: Integer;
    FQuantidade: Currency;
    FSequencia: Integer;
    FValor: Currency;
  published
    property Acrescimo: Currency read FAcrescimo write FAcrescimo;
    property Desconto: Currency read FDesconto write FDesconto;
    property Entrada: Integer read FEntrada write FEntrada;
    property Preco: Currency read FPreco write FPreco;
    property Produto: Integer read FProduto write FProduto;
    property Quantidade: Currency read FQuantidade write FQuantidade;
    property Sequencia: Integer read FSequencia write FSequencia;
    property Valor: Currency read FValor write FValor;
  end;

  { TItemPedido }
  TItemPedido = Class(TObject)
  private
    FAcrescimo: currency;
    FDesconto: currency;
    FId: integer;
    FPedido: integer;
    FProduto: integer;
    FQuantidade: currency;
    FSequencia: integer;
    FStatus: string;
    FValor: currency;
  published
    property Id: integer read FId write FId;
    property Acrescimo: currency read FAcrescimo write FAcrescimo;
    property Desconto: currency read FDesconto write FDesconto;
    property Pedido: integer read FPedido write FPedido;
    property Produto: integer read FProduto write FProduto;
    property Quantidade: currency read FQuantidade write FQuantidade;
    property Sequencia: integer read FSequencia write FSequencia;
    property Status: string read FStatus write FStatus;
    property Valor: currency read FValor write FValor;
  end;

  { TParcelas }
  TParcelas = Class(TObject)
  private
    FData_pagamento: TDateTime;
    FData_vencimento: TDateTime;
    FId: integer;
    FParcela: integer;
    FPedido: integer;
    FStatus: String;
    FValor_pagamento: Currency;
    FValor_parcela: Currency;
  published
    property Data_pagamento: TDateTime read FData_pagamento write FData_pagamento;
    property Data_vencimento: TDateTime read FData_vencimento write FData_vencimento;
    property Id: integer read FId write FId;
    property Parcela: integer read FParcela write FParcela;
    property Pedido: integer read FPedido write FPedido;
    property Status: String read FStatus write FStatus;
    property Valor_pagamento: Currency read FValor_pagamento write FValor_pagamento;
    property Valor_parcela: Currency read FValor_parcela write FValor_parcela;
  end;

  { TPedido }
  TPedido = Class(TObject)
  private
    FAcrescimo: currency;
    FCliente: integer;
    FData: TDateTime;
    FDesconto: currency;
    FID: integer;
    FImposto_chave: string;
    FImposto_fonte: string;
    FObservacao: string;
    FPagamento: Integer;
    FParcelas: Integer;
    FStatus: string;
    FSubtotal: currency;
    FTot_imp_estaduais: currency;
    FTot_imp_federais: currency;
    FTot_imp_municipais: currency;
    FVendedor: integer;
  published
    property Acrescimo: currency Read FAcrescimo Write FAcrescimo;
    property Cliente: integer Read FCliente Write FCliente;
    property Data: TDateTime Read FData Write FData;
    property Desconto: currency Read FDesconto Write FDesconto;
    property Id: integer Read FID Write FId;
    property Imposto_chave: string Read FImposto_chave Write FImposto_chave;
    property Imposto_fonte: string Read FImposto_fonte Write FImposto_fonte;
    property Observacao: string Read FObservacao Write FObservacao;
    property Pagamento: Integer Read FPagamento Write FPagamento;
    property Parcelas: Integer read FParcelas write FParcelas;
    property Status: string Read FStatus Write FStatus;
    property Subtotal: currency Read FSubtotal Write FSubtotal;
    property Tot_imp_estaduais: currency Read FTot_imp_estaduais Write FTot_imp_estaduais;
    property Tot_imp_federais: currency Read FTot_imp_federais Write FTot_imp_federais;
    property Tot_imp_municipais: currency Read FTot_imp_municipais Write FTot_imp_municipais;
    property Vendedor: integer Read FVendedor Write FVendedor;
  end;

  { TPrestacoes - View }
  TPrestacoes = Class(TObject)
  private
    FCliente: Integer;
    FData_compra: TDateTime;
    FData_vencimento: TDateTime;
    FId: Integer;
    FParcela: Integer;
    FParcelas: Integer;
    FPedido: Integer;
    FStatus: String;
    FValor_pagamento: Currency;
    FValor_parcela: Currency;
  published
    property Cliente: Integer read FCliente write FCliente;
    property Data_compra: TDateTime read FData_compra write FData_compra;
    property Data_vencimento: TDateTime read FData_vencimento write FData_vencimento;
    property Id: Integer read FId write FId;
    property Parcela: Integer read FParcela write FParcela;
    property Parcelas: Integer read FParcelas write FParcelas;
    property Pedido: Integer read FPedido write FPedido;
    property Status: String read FStatus write FStatus;
    property Valor_pagamento: Currency read FValor_pagamento write FValor_pagamento;
    property Valor_parcela: Currency read FValor_parcela write FValor_parcela;
  end;


  { TProduto }
  TProduto = Class(TObject)
  private
    FAliquota: Currency;
    FAtivo: Integer;
    FBalanco: Integer;
    FCest: String;
    FData_cad: TDateTime;
    FData_ult_compra: TDateTime;
    FDescricao: String;
    FEan13: String;
    FEstoque: Currency;
    FEstoque_min: Currency;
    FGrupo: Integer;
    FId: Integer;
    FMarca: String;
    FMargem_a_prazo: Currency;
    FMargem_a_vista: Currency;
    FNcm: String;
    FObservacao: String;
    FPreco_compra: Currency;
    FPreco_venda: Currency;
    FReferencia: String;
    FTributacao: String;
    FUnidade: String;
  published
    property Aliquota: Currency Read FAliquota Write FAliquota;
    property Ativo: Integer Read FAtivo Write FAtivo;
    property Balanco: Integer read FBalanco write FBalanco;
    property Cest: String read FCest write FCest;
    property Data_cad: TDateTime Read FData_cad Write FData_cad;
    property Data_ult_compra: TDateTime Read FData_ult_compra Write FData_ult_compra;
    property Descricao: String Read FDescricao Write FDescricao;
    property Ean13: String Read FEan13 Write FEan13;
    property Estoque: Currency Read FEstoque Write FEstoque;
    property Estoque_min: Currency Read FEstoque_min Write FEstoque_min;
    property Grupo: Integer Read FGrupo Write FGrupo;
    property Id: Integer Read FId Write FId;
    property Marca: String Read FMarca Write FMarca;
    property Margem_a_vista: Currency Read FMargem_a_vista Write FMargem_a_vista;
    property Margem_a_prazo: Currency Read FMargem_a_prazo Write FMargem_a_prazo;
    property Ncm: String Read FNcm Write FNcm;
    property Observacao: String Read FObservacao Write FObservacao;
    property Preco_compra: Currency Read FPreco_compra Write FPreco_compra;
    property Preco_venda: Currency Read FPreco_venda Write FPreco_venda;
    property Referencia: String Read FReferencia Write FReferencia;
    property Tributacao: String Read FTributacao Write FTributacao;
    property Unidade: String Read FUnidade Write FUnidade;
  end;


  { TUsuario }
  TUsuario = Class(TObject)
  private
    FEmail : String;
    FId : Integer;
    FLogin : String;
    FNivel : Integer;
    FNome : String;
    FSenha : String;
  published
    Property Email : String Read FEmail Write FEmail;
    Property Id : Integer Read FId Write FId;
    Property Login : String Read FLogin Write FLogin;
    Property Nivel : Integer Read FNivel Write FNivel;
    Property Nome : String Read FNome Write FNome;
    Property Senha : String Read FSenha Write FSenha;
  end;


  {=== Mappers ===}
  TMapCaixa           = specialize TdGSQLdbOpf<TCaixa>;
  TMapClientes        = specialize TdGSQLdbOpf<TCliente>;
  TMapConfiguracoes   = specialize TdGSQLdbOpf<TConfiguracao>;
  TMapDocumentoFiscal = specialize TdGSQLdbOpf<TDocumentoFiscal>;
  TMapEmpresas        = specialize TdGSQLdbOpf<TEmpresa>;
  TMapEntradas        = specialize TdGSQLdbOpf<TEntrada>;
  TMapFormaPgto       = specialize TdGSQLdbOpf<TFormaPgto>;
  TMapFornecedores    = specialize TdGSQLdbOpf<TFornecedor>;
  TMapInfos           = specialize TdGSQLdbOpf<TInfo>;
  TMapItensEntrada    = specialize TdGSQLdbOpf<TItemEntrada>;
  TMapItensPedido     = specialize TdGSQLdbOpf<TItemPedido>;
  TMapGrupos          = specialize TdGSQLdbOpf<TGrupo>;
  TMapParcelas        = specialize TdGSQLdbOpf<TParcelas>;
  TMapPedidos         = specialize TdGSQLdbOpf<TPedido>;
  TMapProdutos        = specialize TdGSQLdbOpf<TProduto>;
  TMapUsuarios        = specialize TdGSQLdbOpf<TUsuario>;

  function con: TdSQLdbConnector;

implementation

var
  _con: TdSQLdbConnector = nil;

function con: TdSQLdbConnector;
begin
  if not Assigned(_con) then
  begin
    _con := TdSQLdbConnector.Create(nil);
    with _con do
    begin
      Logger.Active := True;
      Logger.FileName := ExtractFileDir(ParamStr(0))+PathDelim+'logs'+PathDelim +'LOG.LOG';
      Driver := 'Firebird';
      //Host := '127.0.0.1';
      Database := ExtractFileDir(ParamStr(0))+PathDelim+'sabik_plus.fdb' ;
      User := 'SYSDBA';
      Password := 'masterkey';
      Connect;
    end;
  end;
  Result := _con;
end;

finalization
  FreeAndNil(_con);

end.

