unit u_rules;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, u_models, u_libs, dSQLdbBroker, pingrid, pcnNFe,
  pcnConversao;

type

  {=== Interfaces ====}

  { IGetCliente }
  IGetCliente = Interface
  ['{CB4478DF-CA59-470C-AF6D-61943BA8495D}']
    function nome: string;
    function cpf_cnpj: string;
    function endereco: string;
    function telefone: string;
    function celular: string;
  end;

  { IGetConfig }
  IGetConfig = Interface
  ['{A6886FE2-704A-4944-B5F0-0791D8AF1AEB}']
    function margem_a_vista: currency;
    function margem_a_prazo: currency;
    function grupo_padrao: integer;
  end;

  { IGetFormaPgto }
  IGetFormaPgto = Interface
  ['{5E522263-FE13-4001-85D3-028459999477}']
    function taxa: Currency;
    function periodo: Integer;
    function descricao: String;
  end;

  { IGetFornecedor }
  IGetFornecedor = Interface
  ['{9523B620-937D-4B44-89D4-2F81648A2FFF}']
    function nome: String;
    function cnpj: String;
  end;

  { IGetGrupo }
  IGetGrupo = Interface
  ['{4B4610A7-F3C9-43DE-BCFE-161E7158767B}']
    function nome: String;
    function ncm: String;
    procedure writeInCell(AGrid: TPinGrid; ACol, ARow: Integer);
  end;

  { IGetInfo }
  IGetInfo = Interface
  ['{01FFD1B0-39EC-4732-A579-A2991CE61628}']
    function grupo_padrao: Integer;
    function id_gateway: Integer;
    function token: String;
    function ultimo_backup: TDateTime;
    function versao_bd: String;
  end;

  { IGetItemPedido }
  IGetItemPedido = Interface
  ['{FA4FC46C-A0E6-4D03-B845-7A20428BCBED}']
    procedure remove;
    procedure atualiza(ASequencia: Integer; AQtde, AValor, ADesconto: Double);
  end;

  { IGetPedido }
  IGetPedido = Interface
  ['{B0E99D98-AC25-415F-898C-21C01505BC1A}']
    function valor: Currency;
    function subtotal: Currency;
    function desconto: Currency;
    function cliente: Integer;
    function data: TDateTime;
    function pagamento: Integer;
    function id: Integer;
    function parcelas: Integer;
  end;

  { IGetProduto }
  IGetProduto = Interface
  ['{6083C13F-953E-45C8-9CAB-003E31AFF360}']
    function cest: String;
    function descricao: String;
    function referencia: String;
    function ean13: String;
    function id: Integer;
    function valor: Currency;
    procedure writeInCell(AGrid: TPinGrid; ARow: Integer);
  end;

  { IItemNFe }
  IItemNFe = Interface
  ['{8CA513E8-6ABB-40F0-87B2-4116431819BA}']
    procedure showInGrid(AGrid: TPinGrid);
  end;

  { IModPedido }
  IModPedido = Interface
  ['{126FD660-B986-4705-B575-F119CD1BC740}']
    procedure setPgtoAndParcelas(APgto, AParcelas:  Integer);
  end;

  {=== Classes ===}

  { TGetCliente }
  TGetCliente = class(TInterfacedObject, IGetCliente)
  private
    FNome: string;
    FCpf_cnpj: string;
    FEndereco: string;
    FTelefone: string;
    FCelular: string;
  public
    constructor Create(AId: integer);
    class function new(AId: integer): IGetCliente;
    function nome: string;
    function cpf_cnpj: string;
    function endereco: string;
    function telefone: string;
    function celular: string;
  end;

  { TGetConfig }
  TGetConfig = Class(TInterfacedObject, IGetConfig)
  private
    FMargem_a_vista: currency;
    FMargem_a_prazo: currency;
    FGrupo_padrao: integer;
  public
    constructor Create;
    class function new: IGetConfig;
    function margem_a_vista: currency;
    function margem_a_prazo: currency;
    function grupo_padrao: integer;
  end;

  { TGetFormaPgto }
  TGetFormaPgto = Class(TInterfacedObject, IGetFormaPgto)
  private
    FTaxa: Currency;
    FPeriodo: Integer;
    FDescricao: String;
  public
    constructor Create(AId: Integer);
    class function new(AId: Integer): IGetFormaPgto;
    function taxa: Currency;
    function periodo: Integer;
    function descricao: String;
  end;

  { TGetFornecedor }
  TGetFornecedor = Class(TInterfacedObject, IGetFornecedor)
  private
    FNome: String;
    FCnpj: String;
  public
    constructor Create(AId: Integer);
    class function new(AId: Integer): IGetFornecedor;
    function nome: String;
    function cnpj: String;
  end;

  { TGetGrupo }
  TGetGrupo = Class(TInterfacedObject, IGetGrupo)
  private
    FNome: String;
    FNcm: String;
    FId: Integer;
  public
    constructor Create(AId: Integer);
    class function new(AId: Integer): IGetGrupo;
    function nome: String;
    function ncm: String;
    procedure writeInCell(AGrid: TPinGrid; ACol, ARow: Integer);
  end;

  { TGetInfo }
  TGetInfo = class(TInterfacedObject, IGetInfo)
  private
    FGrupo_padrao: Integer;
    FId_gateway: Integer;
    FToken: String;
    FUltimo_backup: TDateTime;
    FVersaoBD: String;
  public
    constructor Create;
    class function new: IGetInfo;
    function grupo_padrao: Integer;
    function id_gateway: Integer;
    function token: String;
    function ultimo_backup: TDateTime;
    function versao_bd: String;
  end;

  { TGetItemPedido }
  TGetItemPedido = class(TInterfacedObject, IGetItemPedido)
  private
    FId: Integer;
  public
    constructor Create(AId: Integer);
    class function new(AId: Integer): IGetItemPedido;
    procedure remove;
    procedure atualiza(ASequencia: Integer; AQtde, AValor, ADesconto: Double);
  end;

  { TGetPedido }

  TGetPedido = Class(TInterfacedObject, IGetPedido)
  private
    FValor: Currency;
    FSubtotal: Currency;
    FDesconto: Currency;
    FCliente: Integer;
    FData: TDateTime;
    FPagamento: Integer;
    FId: Integer;
    FParcelas: Integer;
  public
    constructor Create(AId: Integer);
    class function new(AId: Integer): IGetPedido;
    function valor: Currency;
    function subtotal: Currency;
    function desconto: Currency;
    function cliente: Integer;
    function data: TDateTime;
    function pagamento: Integer;
    function id: Integer;
    function parcelas: Integer;
  end;


  { TGetProduto }
  TGetProduto = Class(TInterfacedObject, IGetProduto)
  private
    FCest: String;
    FDescricao: String;
    FReferencia: String;
    FEan13: String;
    FId: Integer;
    FGrupo: Integer;
    FPreco_venda: Currency;
  public
    constructor Create(AId: Integer);
    class function new(AId: Integer): IGetProduto;
    function cest: String;
    function descricao: String;
    function referencia: String;
    function ean13: String;
    function id: Integer;
    function valor: Currency;
    procedure writeInCell(AGrid: TPinGrid; ARow: Integer);
  end;


  { TItemNFe }
  TItemNFe = class(TInterfacedObject, IItemNFe)
  private
    FNFe: TNFe;
    FAliquota: double;
    FCEST: string;
    FDescricao: string;
    FEan13: string;
    FItem: string;
    FMarca: string;
    FNCM: string;
    FQtd: double;
    FReferencia: string;
    FTributacao: char;
    FUnidade: string;
    FValorCompra: double;
    FValorVenda: double;
  public
    constructor Create(ANFe: TNFe);
    class function New(ANFe: TNFe): IItemNFe;
    procedure showInGrid(AGrid: TPinGrid);
    property Item: string read FItem write FItem;
    property Ean13: string read FEan13 write FEan13;
    property Referencia: string read FReferencia write FReferencia;
    property Descricao: string read FDescricao write FDescricao;
    property ValorCompra: double read FValorCompra write FValorCompra;
    property ValorVenda: double read FValorVenda write FValorVenda;
    property Qtd: double read FQtd write FQtd;
    property NCM: string read FNCM write FNCM;
    property Marca: string read FMarca write FMarca;
    property Unidade: string read FUnidade write FUnidade;
    property Tributacao: char read FTributacao write FTributacao;
    property Aliquota: double read FAliquota write FAliquota;
    property CEST: string read FCEST write FCEST;
  end;

  { TModPedido }

  TModPedido = class(TInterfacedObject, IModPedido)
  private
    FId: Integer;
  public
    constructor Create(AId: Integer);
    class function new(AId: Integer): IModPedido;
    procedure setPgtoAndParcelas(APgto, AParcelas:  Integer);
  end;


implementation

{ TGetConfig }

constructor TGetConfig.Create;
var
  Config: TConfiguracao;
  Configs: TMapConfiguracoes;
begin
  FMargem_a_vista := 0;
  FMargem_a_prazo := 0;
  FGrupo_padrao := 0;
  Config := TConfiguracao.Create;
  Configs := TMapConfiguracoes.Create(con, 'configuracoes');
  try
    Config.Id := 1;
    if Configs.Get(Config) then
    begin
      FMargem_a_vista := Config.Margem_a_vista;
      FMargem_a_prazo := Config.Margem_a_prazo;
      FGrupo_padrao   := Config.Grupo_padrao;
    end;
  finally
    Config.Free;
    Configs.Free;
  end;
end;

class function TGetConfig.new: IGetConfig;
begin
  Result := Create;
end;

function TGetConfig.margem_a_vista: currency;
begin
  Result := FMargem_a_vista;
end;

function TGetConfig.margem_a_prazo: currency;
begin
  Result := FMargem_a_prazo;
end;

function TGetConfig.grupo_padrao: integer;
begin
  Result := FGrupo_padrao;
end;

{ TModPedido }

constructor TModPedido.Create(AId: Integer);
begin
  FId := AId;
end;

class function TModPedido.new(AId: Integer): IModPedido;
begin
  Result := Create(AId);
end;

procedure TModPedido.setPgtoAndParcelas(APgto, AParcelas: Integer);
var
  Pedido: TPedido;
  Pedidos: TMapPedidos;
begin
  Pedido := TPedido.Create;
  Pedidos := TMapPedidos.Create(con, 'pedidos');
  try
    Pedido.Id := FId;
    Pedidos.Get(Pedido);
    Pedido.Pagamento := APgto;
    Pedido.Parcelas  := AParcelas;
    Pedidos.Modify(Pedido);
    Pedidos.Apply;
  finally
    Pedido.Free;
    Pedidos.Free;
  end;
end;

{ TGetFormaPgto }
constructor TGetFormaPgto.Create(AId: Integer);
var
  FormaPgto: TFormaPgto;
  FormaPgtos: TMapFormaPgto;
begin
  FTaxa := 0.0;
  FPeriodo := 0;
  FDescricao := 'A VISTA';
  FormaPgto := TFormaPgto.Create;
  FormaPgtos := TMapFormaPgto.Create(con, 'forma_pgto');
  try
    FormaPgto.Id := AId;
    FormaPgtos.Get(FormaPgto);
    FTaxa      := FormaPgto.Taxa;
    FPeriodo   := FormaPgto.Periodo_lancamento;
    FDescricao := FormaPgto.Descricao;
  finally
    FormaPgto.Free;
    FormaPgtos.Free;
  end;
end;

class function TGetFormaPgto.new(AId: Integer): IGetFormaPgto;
begin
  Result := Create(AId);
end;

function TGetFormaPgto.taxa: Currency;
begin
  Result := FTaxa;
end;

function TGetFormaPgto.periodo: Integer;
begin
  Result := FPeriodo;
end;

function TGetFormaPgto.descricao: String;
begin
  Result := FDescricao;
end;

{ TGetPedido }
constructor TGetPedido.Create(AId: Integer);
var
  Pedido: TPedido;
  Pedidos: TMapPedidos;
begin
  FValor     := 0;
  FSubtotal  := 0;
  FDesconto  := 0;
  FCliente   := 0;
  FData      := Date;
  FPagamento := 0;
  FId        := AId;
  FParcelas  := 0;
  Pedido     := TPedido.Create;
  Pedidos    := TMapPedidos.Create(con, 'pedidos');
  try
    Pedido.Id    := AId;
    Pedidos.Get(Pedido);
    FSubtotal    := Pedido.Subtotal;
    FDesconto    := Pedido.Desconto;
    FValor       := Pedido.Subtotal - Pedido.Desconto;
    FCliente     := Pedido.Cliente;
    FData        := Pedido.Data;
    FPagamento   := Pedido.Pagamento;
    FParcelas    := Pedido.Parcelas;
  finally
    Pedido.Free;
    Pedidos.Free;
  end;
end;

class function TGetPedido.new(AId: Integer): IGetPedido;
begin
  Result := Create(AId);
end;

function TGetPedido.valor: Currency;
begin
  Result := FValor;
end;

function TGetPedido.subtotal: Currency;
begin
  Result := FSubtotal;
end;

function TGetPedido.desconto: Currency;
begin
  Result := FDesconto;
end;

function TGetPedido.cliente: Integer;
begin
  Result := FCliente;
end;

function TGetPedido.data: TDateTime;
begin
  Result := FData;
end;

function TGetPedido.pagamento: Integer;
begin
  Result := FPagamento;
end;

function TGetPedido.id: Integer;
begin
  Result := FId;
end;

function TGetPedido.parcelas: Integer;
begin
  Result := FParcelas;
end;

{ TGetItemPedido }

constructor TGetItemPedido.Create(AId: Integer);
begin
  FId := AId;
end;

class function TGetItemPedido.new(AId: Integer): IGetItemPedido;
begin
  Result := Create(AId);
end;

procedure TGetItemPedido.remove;
var
  Item: TItemPedido;
  Items: TMapItensPedido;
begin
  Item  := TItemPedido.Create;
  Items := TMapItensPedido.Create(con, 'itens_pedidos');
  try
    Item.Id := FId;
    Items.Remove(Item);
    Items.Apply;
  finally
    Item.Free;
    Items.Free;
  end;
end;

procedure TGetItemPedido.atualiza(ASequencia: Integer; AQtde, AValor,
  ADesconto: Double);
var
  Item: TItemPedido;
  Items: TMapItensPedido;
begin
  Item  := TItemPedido.Create;
  Items := TMapItensPedido.Create(con, 'itens_pedidos');
  try
    Item.Id := FId;
    Items.Get(Item);
    Item.Sequencia  := ASequencia;
    Item.Quantidade := AQtde;
    Item.Valor      := AValor;
    Item.Desconto   := ADesconto;
    Items.Modify(Item);
    Items.Apply;
  finally
    Item.Free;
    Items.Free;
  end;
end;

{ TGetCliente }
constructor TGetCliente.Create(AId: integer);
var
  Cliente: TCliente;
  Clientes: TMapClientes;
begin
  FNome       := '';
  FCpf_cnpj   := '';
  FEndereco   := '';
  FTelefone   := '';
  FCelular    := '';
  Cliente     := TCliente.Create;
  Clientes    := TMapClientes.Create(con, 'clientes');
  try
    Cliente.Id := AId;
    if Clientes.Get(Cliente) then
    begin
      FNome      := Cliente.Nome;
      FCpf_cnpj  := Cliente.Cpf_cnpj;
      FEndereco  := Cliente.Endereco;
      FTelefone  := Cliente.Telefone_1;
      FCelular   := Cliente.Celular_1;
    end;
  finally
    Cliente.Free;
    Clientes.Free;
  end;
end;

class function TGetCliente.new(AId: integer): IGetCliente;
begin
  Result := Create(AId);
end;

function TGetCliente.nome: string;
begin
  Result := FNome;
end;

function TGetCliente.cpf_cnpj: string;
begin
  Result := FCpf_cnpj;
end;

function TGetCliente.endereco: string;
begin
  Result := FEndereco;
end;

function TGetCliente.telefone: string;
begin
  Result := FTelefone;
end;

function TGetCliente.celular: string;
begin
  Result := FCelular;
end;

{ TGetProduto }
constructor TGetProduto.Create(AId: Integer);
var
  Produto: TProduto;
  Produtos: TMapProdutos;
begin
  if AId < 1 then Exit;
  FCest        := '';
  FDescricao   := '';
  FReferencia  := '';
  FEan13       := '';
  FId          := AId;
  FGrupo       := TGetInfo.new.grupo_padrao;
  FPreco_venda := 0;
  Produto      := TProduto.Create;
  Produtos     := TMapProdutos.Create(con, 'produtos');
  try
    Produto.Id := AId;
    if Produtos.Get(Produto) then
    begin
      FCest        := Produto.Cest;
      FDescricao   := Produto.Descricao;
      FReferencia  := Produto.Referencia;
      FEan13       := Produto.Ean13;
      FGrupo       := Produto.Grupo;
      FId          := Produto.Id;
      FPreco_venda := Produto.Preco_venda;
    end;
  finally
    Produto.Free;
    Produtos.Free;
  end;
end;

class function TGetProduto.new(AId: Integer): IGetProduto;
begin
  Result := Create(AId);
end;

function TGetProduto.cest: String;
begin
  Result := FCest;
end;

function TGetProduto.descricao: String;
begin
  Result := FDescricao;
end;

function TGetProduto.referencia: String;
begin
  Result := FReferencia;
end;

function TGetProduto.ean13: String;
begin
  Result := FEan13;
end;

function TGetProduto.id: Integer;
begin
  Result := FId;
end;

function TGetProduto.valor: Currency;
begin
  Result := FPreco_venda;
end;

procedure TGetProduto.writeInCell(AGrid: TPinGrid; ARow: Integer);
begin
  AGrid.TagCell[0, ARow] := FId;
  TGetGrupo.New(FGrupo).writeInCell(AGrid, 1, ARow);
  if AGrid.Cells[2, ARow] = '' then AGrid.Cells[2, ARow] := FEan13;
  if AGrid.Cells[3, ARow] = '' then AGrid.Cells[3, ARow] := FReferencia;
end;

{ TGetFornecedor }
constructor TGetFornecedor.Create(AId: Integer);
var
  Fornecedor: TFornecedor;
  Fornecedores: TMapFornecedores;
begin
  FNome  := '';
  FCnpj   := '';
  Fornecedor := TFornecedor.Create;
  Fornecedores := TMapFornecedores.Create(con, 'fornecedores');
  try
    Fornecedor.Id := AId;
    if Fornecedores.Get(Fornecedor) then
    begin
      FNome  := Fornecedor.Nome;
      FCnpj  := Fornecedor.Cnpj;
    end;
  finally
    Fornecedor.Free;
    Fornecedores.Free;
  end;
end;

class function TGetFornecedor.new(AId: Integer): IGetFornecedor;
begin
  Result := Create(AId);
end;

function TGetFornecedor.nome: String;
begin
  Result := FNome;
end;

function TGetFornecedor.cnpj: String;
begin
  Result := FCnpj;
end;

{ TGetInfo }

constructor TGetInfo.Create;
var
  Info: TInfo;
  Infos: TMapInfos;
begin
  FGrupo_padrao := 0;
  FId_gateway := 0;
  FToken := '';
  FUltimo_backup := 0;
  Info := TInfo.Create;
  Infos := TMapInfos.Create(con, 'info');
  try
    Info.Id := 1;
    if Infos.Get(Info) then
    begin
      FGrupo_padrao  := Info.Grupo_padrao;
      FId_gateway    := Info.Id_gateway;
      FToken         := Decifra(16, '1046', Info.Token);
      FUltimo_backup := Info.Ultimo_backup;
      FVersaoBD      := Info.Versao_bd;
    end;
  finally
    Info.Free;
    Infos.Free;
  end;
end;

class function TGetInfo.new: IGetInfo;
begin
  Result := Create;
end;

function TGetInfo.grupo_padrao: Integer;
begin
  Result := FGrupo_padrao;
end;

function TGetInfo.id_gateway: Integer;
begin
  Result := FId_gateway;
end;

function TGetInfo.token: String;
begin
  Result := FToken;
end;

function TGetInfo.ultimo_backup: TDateTime;
begin
  Result := FUltimo_backup;
end;

function TGetInfo.versao_bd: String;
begin
  Result := FVersaoBD;
end;

{ TItemNFe }

constructor TItemNFe.Create(ANFe: TNFe);
begin
  if Assigned(ANFe) then FNFe := ANFe;
end;

class function TItemNFe.New(ANFe: TNFe): IItemNFe;
begin
  Result := Create(ANFe);
end;

procedure TItemNFe.showInGrid(AGrid: TPinGrid);
var
  Produto: TProduto;
  Produtos: TMapProdutos;
  i, j: Integer;
  //VInfo: IGetInfo;
  VMargem_a_vista, VMargem_a_prazo: Currency;
  VConfig: IGetConfig;
begin
  Produto := TProduto.Create;
  Produtos := TMapProdutos.Create(con, 'produtos');
  VConfig := TGetConfig.new;
  try
    AGrid.RowCount := FNFe.Det.Count + 1;
    with FNFe.Det do
    for i := 0 to Count - 1 do
    begin
      with Items[i] do
      begin
        j := i + 1;
        {=== Verifica existência na tabela Produtos ===}
        Produto.Ean13 := Prod.cEAN;
        Produto.Referencia := Prod.cProd;
        {=== Verifica se encontra por código de barras ===}
        { TODO : Refatorar isso! Talvez retirar a validação de vazio }
        if (Trim(Prod.cEAN) <> '') and Produtos.Find(Produto, 'ean13 = :ean13') then
        begin
          AGrid.TagCell[0, j] := Produto.Id;
          AGrid.TagCell[2, j] := 1;
        end
        {=== Verifica se encontra por referência ===}
        else if (Trim(Prod.cProd) <> '') and Produtos.Find(Produto, 'referencia = :referencia') then
        begin
          AGrid.TagCell[0, j] := Produto.Id;
          AGrid.TagCell[3, j] := 1;
        end
          {=== Caso contrário, atribui zero na TagCell da coluna zero ===}
        else
          AGrid.TagCell[0, j] := 0;
        {=== Preenche a coluna 1 com o número do item na NFe ===}
        AGrid.Cells[0, j] := IntToStr(Prod.nItem);
        {=== Verificar qual grupo e colocar na 2 coluna do Grid ===}
        TGetGrupo.new(ifthen(AGrid.TagCell[0, j] = 0, 0, Produto.Grupo)
        ).writeInCell(AGrid, 1, j);
        {=== Preenche as demais linhas do Grid ===}
        AGrid.Cells[2, j] := Prod.cEAN;
        AGrid.Cells[3, j] := Prod.cProd;
        AGrid.Cells[4, j] := Prod.xProd;
        {=== Verifica se o emitente é do simples nacional (1) ===}
        if CRTToStr(FNFe.Emit.CRT) = '1' then
        begin
          {=== Identifica a tribut. de ICMS pelo CSOSN (Simples Nacional) ===}
          case StrToInt(CSOSNIcmsToStr(Imposto.ICMS.CSOSN)) of
            101, 102: AGrid.TagCell[5, j] := 0; {=== Tributado ===}
            103, 300: AGrid.TagCell[5, j] := 1; {=== Isento ===}
            400: AGrid.TagCell[5, j] := 2; {=== Não incidente ===}
          else
            AGrid.TagCell[5, j] := 3; {=== Substituição ===}
          end;
        end
        else
        begin
          {=== Identifica a tribut. de ICMS pelo CST (Regime Normal) ===}
          case StrToInt(CSTICMSToStr(Imposto.ICMS.CST)) of
            0, 20: AGrid.TagCell[5, j] := 0;
            40: AGrid.TagCell[5, j] := 1; {=== Isento ===}
            41: AGrid.TagCell[5, j] := 2; {=== Não incidente ===}
          else
            AGrid.TagCell[5, j] := 3; {=== Substituição ===}
          end;
        end;

        {=== Pegar a margem do produto, caso ele já esteja cadastrado  ===}
        if (AGrid.TagCell[0, j] <> 0) then
        begin
          VMargem_a_vista := Produto.Margem_a_vista;
          VMargem_a_prazo := Produto.Margem_a_prazo;
        end
        else
        begin
          VMargem_a_vista := VConfig.margem_a_vista;
          VMargem_a_prazo := VConfig.margem_a_prazo;
        end;
        {=== Preenche as colunas de preços, qtd e und ===}
        AGrid.Cells[6, j]  := Prod.vUnCom.to_m;
        AGrid.Cells[7, j]  := FormatFloat('### ###,##0.00', Prod.vUnCom * (1 + VMargem_a_vista / 100));
        AGrid.Cells[8, j]  := FormatFloat('### ###,##0.00', Prod.vUnCom * (1 + VMargem_a_prazo / 100));
        AGrid.Cells[9, j]  := Prod.qCom.to_s;
        AGrid.Cells[10, j]  := Prod.uCom;
        AGrid.Cells[12, j] := Prod.NCM;
        AGrid.Cells[13, j] := VMargem_a_vista.to_s;
        AGrid.Cells[14, j] := VMargem_a_prazo.to_s;
        AGrid.Cells[15, j] := Prod.CEST;
      end;
    end;
  finally
    AGrid.SetFocus;
    Produto.Free;
    Produtos.Free;
  end;
end;

{ TGetGrupo }

constructor TGetGrupo.Create(AId: Integer);
var
  Grupos: TMapGrupos;
  Grupo:  TGrupo;
begin
  FNome  := '';
  FNcm   := '';
  FId    := AId;
  Grupos := TMapGrupos.Create(con, 'grupos');
  Grupo  := TGrupo.Create;
  try
    Grupo.Id := AId;
    if (not Grupos.Get(Grupo)) or (AId = 0) then
    begin
      Grupo.Id := TGetInfo.new.grupo_padrao;
      Grupos.Get(Grupo);
    end;
    FNome := Grupo.Nome;
    FNcm  := Grupo.Ncm_padrao;
    FId   := Grupo.Id;
  finally
    Grupo.Free;
    Grupos.Free;
  end;
end;

class function TGetGrupo.new(AId: Integer): IGetGrupo;
begin
  Result := Create(AId);
end;

function TGetGrupo.nome: String;
begin
  Result := FNome;
end;

function TGetGrupo.ncm: String;
begin
  Result := FNcm;
end;

procedure TGetGrupo.writeInCell(AGrid: TPinGrid; ACol, ARow: Integer);
begin
  AGrid.TagCell[ACol, ARow] := FId;
  AGrid.Cells[ACol, ARow] := FNome;
end;

end.

