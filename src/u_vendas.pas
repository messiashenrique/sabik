unit u_vendas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, Menus, u_libs, u_models, u_rules, u_dm, u_busca_produto,
  u_busca_cliente, u_pagamento, u_checkout, pingrid, strutils, Types, math,
  Grids, Buttons, EditBtn, dSQLdbBroker, dUtils;

type

  { TfrmVendas }

  TfrmVendas = class(TForm)
    btnBuscar: TBitBtn;
    btnCancel: TBitBtn;
    btnCondicional: TBitBtn;
    btnDefineCliente: TBitBtn;
    btnNew: TBitBtn;
    btnSave: TBitBtn;
    btnAdd: TBitBtn;
    btnDelete: TBitBtn;
    btnFaturar: TBitBtn;
    deDataPedido: TDateEdit;
    deStart: TDateEdit;
    deEnd: TDateEdit;
    edDesconto: TLabel;
    edEndereco: TLabel;
    edCpfCnpj: TLabel;
    edSearchProdutos: TEdit;
    edSubtotal: TLabel;
    edTelefone: TLabel;
    edNF: TLabel;
    edCliente: TLabel;
    edSearch: TEdit;
    edCelular: TLabel;
    edTotal: TLabel;
    fcpf_cnpj: TLabel;
    fSubtotal: TLabel;
    fDtEmissao: TLabel;
    fDtpedido: TLabel;
    fFormaPgto: TLabel;
    fVenda: TLabel;
    fRz: TLabel;
    fTotal: TLabel;
    fDesconto: TLabel;
    gridSearch: TPinGrid;
    gridDetails: TPinGrid;
    gridLista: TPinGrid;
    gridVenda: TPinGrid;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    img16: TImageList;
    imlEntries: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    lbCNPJ1: TLabel;
    lbDesconto: TLabel;
    lbRodapeSearch: TLabel;
    lbRodapeSearch1: TLabel;
    lbSubt: TLabel;
    lbDtEmi1: TLabel;
    lbDtEnt1: TLabel;
    lbFornecedor1: TLabel;
    labell: TLabel;
    lbIE1: TLabel;
    lbNF1: TLabel;
    lbFormaPgto: TLabel;
    lbSubtotal: TLabel;
    lbTitulo: TLabel;
    lbChave: TLabel;
    lbCNPJ: TLabel;
    lbDtEnt: TLabel;
    lbFornecedor: TLabel;
    lbNF: TLabel;
    lbIE: TLabel;
    lbTitulo1: TLabel;
    lbTitulo2: TLabel;
    lbTitulo3: TLabel;
    lbTotal: TLabel;
    lbValorTotal: TLabel;
    lbDesc: TLabel;
    pnValores: TPanel;
    pnVenda: TPanel;
    pbSearch: TPanel;
    pg: TPageControl;
    pnConctroles: TPanel;
    pnListaTop: TPanel;
    pnPedidosTop: TPanel;
    pnTopDetails: TPanel;
    rgOrdem: TRadioGroup;
    rgStatus: TRadioGroup;
    rgSearchVenda: TRadioGroup;
    sb: TStatusBar;
    Splitter1: TSplitter;
    tbLista: TTabSheet;
    tbVenda: TTabSheet;
    tbDetails: TTabSheet;
    procedure btnAddClick(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnCondicionalClick(Sender: TObject);
    procedure btnDefineClienteClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnFaturarClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure deDataPedidoChange(Sender: TObject);
    procedure edSearchProdutosChange(Sender: TObject);
    procedure edSearchProdutosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure gridListaDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure gridSearchDblClick(Sender: TObject);
    procedure gridSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gridVendaDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure gridVendaKeyPress(Sender: TObject; var Key: char);
    procedure gridVendaMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure gridVendaSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure gridVendaValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
    procedure gridListaDblClick(Sender: TObject);
    procedure rgOrdemSelectionChanged(Sender: TObject);
    procedure rgSearchVendaSelectionChanged(Sender: TObject);
    procedure rgStatusSelectionChanged(Sender: TObject);
    procedure sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure tbDetailsShow(Sender: TObject);
    procedure tbListaShow(Sender: TObject);
    procedure tbVendaShow(Sender: TObject);
  private
    procedure AddPedido;
    procedure AddItem(AId: Integer);
    procedure DeletarItem(aRow: Integer);
    procedure PreencherCliente;
    procedure SubtotalizaItem(ARow: Integer);
    procedure SubtotalizaPedido;
    procedure ClearPedido;
    procedure RegistraItem(RowGrid, AIdPedido: Integer); overload;
    procedure RegistraItem(Sequencia, RowGrid, AIdPedido: Integer); overload;
    procedure Cancelar;
    procedure DefinirCliente;
    procedure CarregarPedidos;
    procedure CarregarDetalhes(AId: Integer);
    procedure ReabrirPedido(AId: Integer);
    procedure ConciliaAlteracoes(AId: Integer; AStatus: String = 'A');
    procedure ModificarPedido(AId: Integer; AStatus: String);
    procedure search(AScript: String);
    procedure searchDefault;
    function Salvar(AStatus: String = 'A'): Integer;
    function RegistraPedido: Integer;
    function VerificaAlteracoesNoPedido(AStatus: String): Boolean;
    {private declarations}
  public
    {public declarations}
  end;

var
  frmVendas: TfrmVendas;

implementation

{$R *.lfm}

{ TfrmVendas }

procedure TfrmVendas.btnNewClick(Sender: TObject);
begin
  AddPedido;
end;

procedure TfrmVendas.btnCancelClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TfrmVendas.btnCondicionalClick(Sender: TObject);
begin
  {=== Salva e altera o status para condicional ===}
  Salvar('C');
  tbLista.Show;
end;

procedure TfrmVendas.btnDefineClienteClick(Sender: TObject);
begin
  {=== Define cliente para o pedido ===}
  DefinirCliente;
end;

procedure TfrmVendas.btnDeleteClick(Sender: TObject);
begin
  {=== Remove item selecionado ===}
  if (gridVenda.RowCount < 2) then Exit;
  DeletarItem(gridVenda.Row);
end;

procedure TfrmVendas.btnFaturarClick(Sender: TObject);
var
  VIdPedido: Integer;
begin
  {=== Salva e fatura o pedido ===}
  VIdPedido := Salvar();
  if VIdPedido > 0 then
    createFormWithTag(TfrmCheckout, frmCheckout, VIdPedido);
  tbLista.Show;
end;

procedure TfrmVendas.btnAddClick(Sender: TObject);
begin
  {=== Adicionar Item ao pedido ===}
  if gridSearch.RowCount > 1 then
    AddItem(gridSearch.TagCell[0, gridSearch.Row]);
end;

procedure TfrmVendas.btnBuscarClick(Sender: TObject);
begin
  CarregarPedidos;
end;

procedure TfrmVendas.btnSaveClick(Sender: TObject);
begin
  {=== Salvar pedido ===}
  {=== Caso a tag da tab seja 2 é porque é condicional ===}
  Salvar(ifthen(tbVenda.Tag=2, 'C', 'A'));
  tbLista.Show;
end;

procedure TfrmVendas.deDataPedidoChange(Sender: TObject);
begin
  {=== A data foi alterada ===}
  deDataPedido.Tag := 1;
end;

procedure TfrmVendas.edSearchProdutosChange(Sender: TObject);
var
  p: String;
begin
  p := '''%'+edSearchProdutos.Text.raw+'%''';
  if (Length(edSearchProdutos.Text) > 0) then
    search('select id, descricao, preco_venda, estoque from produtos where'+
           '(id>0) and ((descricao like '+p+') or (id like '+p+') or (ean13 '+
           'like '+p+') or (referencia like '+p+'))')
  else
    searchDefault;
end;

procedure TfrmVendas.edSearchProdutosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key = 40) or (Key = 13)) and (gridSearch.RowCount > 1) then
    gridSearch.SetFocus;
end;

procedure TfrmVendas.FormCreate(Sender: TObject);
begin
  pg.ShowTabs := False;
end;

procedure TfrmVendas.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if tbLista.Showing then
    case key of
    //114: SetSearch;      {===F3====}
      116: AddPedido;      {===F5====}
    //117: EditRegister;   {===F6====}
    //119: RemoverEntrada; {===F8====}
    //121: Salvar;         {===F10===}
       27: Cancelar;       {===Esc===}
    end
  else if tbVenda.Showing then
    case Key of
      114: edSearchProdutos.SetFocus; {=== F3 ===}
      116: btnAdd.Click;              {===F5====}
      //119: RemoverEntrada;          {===F8====}
      121: Salvar;                    {===F10===}
       27: Cancelar;                  {===Esc===}
    end
  else
    case Key of
      //116: AddItem;        {===F5====}
      //119: RemoverEntrada; {===F8====}
      //121: Salvar;         {===F10===}
      27: Cancelar;       {===Esc===}
    end;
end;

procedure TfrmVendas.FormShow(Sender: TObject);
begin
  tbLista.Show;
  tbLista.SetFocus;
end;

procedure TfrmVendas.gridListaDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  S: String;
  VStatus: Integer;
const
  ArrayColor: Array[0..2] of TColor=($00E6E6FF, $00FFE1C4, $00F5FFEC);
begin
  if aRow = 0 then Exit;
  if (aCol=6) then
  begin
    S := Trim(gridLista.Cells[6, aRow]);
    VStatus := AnsiIndexStr(S, ['A', 'C', 'F']);
    case VStatus of
      0: S := 'aberto';
      1: S := 'condicional';
      2: S := 'faturado';
    end;
    gridLista.Canvas.Brush.Color := ArrayColor[VStatus];
    gridLista.Canvas.FillRect(aRect);
    gridLista.Canvas.TextRect(aRect, aRect.Left + 25, aRect.Top, S);
    img16.Draw(gridLista.Canvas, aRect.Left + 3, aRect.Top + 1, VStatus);
  end;
end;

procedure TfrmVendas.gridSearchDblClick(Sender: TObject);
begin
  if gridSearch.RowCount > 1 then
    AddItem(gridSearch.TagCell[0, gridSearch.Row]);
end;

procedure TfrmVendas.gridSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 13) and (gridSearch.RowCount > 1) then
    AddItem(gridSearch.TagCell[0, gridSearch.Row]);
end;

procedure TfrmVendas.gridVendaDrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  S: String;
begin
  if aRow = 0 then Exit;
  S := gridVenda.Cells[aCol, aRow];
  if (aCol=0) then S := aRow.to_s;
  if (gdSelected in aState) then gridVenda.Canvas.Brush.Color := $00FDF1CE;
  gridVenda.Canvas.FillRect(aRect);
  //gridVenda.Canvas.TextRect(aRect, aRect.Left, aRect.Top, S);
  if (gridVenda.Cells[9, aRow] = 'deletado') then
  begin
    gridVenda.Canvas.Brush.Color := clGray;
    gridVenda.Canvas.Font.Color  := clGrayText;
    gridVenda.Canvas.Pen.Width   := 3;
    gridVenda.Canvas.Pen.Color   := clRed;
    gridVenda.Canvas.Line(aRect.Left, aRect.Top + 9, aRect.Right, aRect.Top + 9);
  end;
  //gridVenda.Canvas.FillRect(aRect);
  gridVenda.Canvas.TextRect(aRect, aRect.Left, aRect.Top, S);
end;

procedure TfrmVendas.gridVendaKeyPress(Sender: TObject; var Key: char);
var
  aCol, aRow: Integer;
begin
  aCol := gridVenda.Col;
  aRow := gridVenda.Row;
  if (gridVenda.Cells[9, aRow] = 'deletado') then Key := #0;
  {=== Trata a entrada de teclas na coluna da tributação ===}
  if Key = #13 then Exit;
  {=== Tratar cada coluna em particular ===}
  case aCol of
    4: Key := OnlyKeyNumbers(Key);
    7: Key := OnlyKeyMoney(Key);
  end;
end;

procedure TfrmVendas.gridVendaMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  C, R: Longint;
begin
  gridVenda.MouseToCell(X, Y, C, R);
  if gridVenda.Mark[C, R] then
    case C of
      4: Hint := 'Esse campo não pode ficar em branco.';
    end
  else
    Hint := gridVenda.Cells[C, R];
end;

procedure TfrmVendas.gridVendaSelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
var
  S, S_error: String;
begin
  case aCol of
    4: S := 'Para modificar, basta digitar uma nova quantidade.';
    7: S := 'Digite o valor do desconto (R$) aplicado sobre o subtotal.'
  else S := 'F5-Para adicionar item | F8-Para excluir o item | F10-Para faturar | F12-Para condicional | Esc-Para voltar';
  end;

  case aCol of
    7: S_error := 'O valor de desconto acima do permitido.';
  end;
  sb.Panels[0].Text := 'Dica:';
  sb.Panels[1].Text := S;
  sb.Panels[2].Text := ifthen(gridVenda.Mark[aCol, aRow], 'Erro:', '');
  sb.Panels[3].Text := IfThen(gridVenda.Mark[aCol, aRow], S_error, '');
end;

procedure TfrmVendas.gridVendaValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
begin
  if (aRow = 0) then Exit;
  case aCol of
    3: gridVenda.Mark[aCol, aRow] := (NewValue.to_f <= 0);
    4: NewValue := NewValue.to_m;
    6: begin
      gridVenda.Mark[aCol, aRow] := (gridVenda.Cells[5, aRow].to_f < 2 * NewValue.to_f);
      NewValue := NewValue.to_m;
    end;
  end;
  if (aCol in [3, 4, 6]) then
    gridVenda.Cells[9, aRow] := ifthen(Trim(OldValue) <> Trim(NewValue), 'modificado', '');
  SubtotalizaItem(aRow);
end;

procedure TfrmVendas.gridListaDblClick(Sender: TObject);
begin
  if ((gridLista.RowCount>1) and (gridLista.Row>0)) then
    if (gridLista.TagCell[6, gridLista.Row]=2) then
      CarregarDetalhes(gridLista.TagCell[0, gridLista.Row]) {=== Faturada ===}
    else
      ReabrirPedido(gridLista.TagCell[0, gridLista.Row]);
end;

procedure TfrmVendas.rgOrdemSelectionChanged(Sender: TObject);
begin
  CarregarPedidos;
end;

procedure TfrmVendas.rgSearchVendaSelectionChanged(Sender: TObject);
begin
  edSearch.Enabled := rgSearchVenda.ItemIndex = 0;
  deStart.Enabled  := rgSearchVenda.ItemIndex = 1;
  deEnd.Enabled    := rgSearchVenda.ItemIndex = 1;
end;

procedure TfrmVendas.rgStatusSelectionChanged(Sender: TObject);
begin
  CarregarPedidos;
end;

procedure TfrmVendas.sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  sb.Canvas.Font.Color := clDefault;
  case Panel.Index of
    0: img16.Draw(sb.Canvas, Rect.Left, Rect.Top, 7);
    2: if Panel.Text <> '' then img16.Draw(sb.Canvas, Rect.Left, Rect.Top, 6);
    3: sb.Canvas.Font.Color := clRed;
  end;
  sb.Canvas.Font.Bold := Panel.Index in [2,3];
  sb.Canvas.TextRect(Rect, Rect.Left + ifthen(Panel.Index in [0,2], 18, 0), Rect.Top, Panel.Text)
end;

procedure TfrmVendas.tbDetailsShow(Sender: TObject);
begin
  sb.Panels[0].Text := 'Dica:';
  sb.Panels[1].Text := 'Esc-Para voltar';
  sb.Panels[2].Text := '';
  sb.Panels[3].Text := '';
  gridDetails.SetFocus;
end;

procedure TfrmVendas.tbListaShow(Sender: TObject);
begin
  sb.Panels[0].Text := 'Dica:';
  sb.Panels[1].Text := 'F5-Para novo pedido | Esc-Para sair';
  sb.Panels[2].Text := '';
  sb.Panels[3].Text := '';
  deStart.Date := Date - 30;
  deEnd.Date   := Date;
  CarregarPedidos;
end;

procedure TfrmVendas.tbVendaShow(Sender: TObject);
begin
  btnCondicional.Visible := tbVenda.Tag <> 2;
  btnCondicional.Enabled := tbVenda.Tag <> 2;
  sb.Panels[0].Text := 'Dica:';
  sb.Panels[1].Text := 'F5-Para adicionar item  |  F8-Remover item  |  F10-Salvar orçamento  |  F12-Faturar venda  |  Esc-Para cancelar';
  sb.Panels[2].Text := '';
  sb.Panels[3].Text := '';
  edSearchProdutos.SetFocus;
end;

procedure TfrmVendas.AddPedido;
begin
  ClearPedido;
  tbVenda.Show;
end;

procedure TfrmVendas.AddItem(AId: Integer);
var
  Produto: IGetProduto;
  VLinha: Integer;
begin
  Produto := TGetProduto.new(AId);
  if (Produto.id = 0) then Exit;
  VLinha := gridVenda.RowCount;
  gridVenda.RowCount := gridVenda.RowCount + 1;
  gridVenda.Cells[1, VLinha] := Produto.referencia;
  gridVenda.Cells[2, VLinha] := Produto.descricao;
  gridVenda.Cells[3, VLinha] := '1';
  gridVenda.Cells[4, VLinha] := Produto.valor.to_m;
  gridVenda.Cells[8, VLinha] := Produto.id.to_s;
  SubtotalizaItem(VLinha);
  gridSearch.RowCount := 1;
  lbRodapeSearch.Caption := '';
  edSearchProdutos.Clear;
  searchDefault;
  edSearchProdutos.SetFocus;
end;

procedure TfrmVendas.PreencherCliente;
var
  VCliente: IGetCliente;
begin
  VCliente := TGetCliente.new(edCliente.Tag);
  edCliente.Caption   := VCliente.nome;
  edEndereco.Caption  := VCliente.endereco;
  edTelefone.Caption  := VCliente.telefone.maskPhone;
  edCelular.Caption   := VCliente.celular.maskCellPone;
  edCpfCnpj.Caption   := VCliente.cpf_cnpj.maskCpfCnpj;
end;

function TfrmVendas.RegistraPedido: Integer;
var
  VControle: String;
  Pedidos: TMapPedidos;
  Pedido: TPedido;
begin
  Result := 0;

  Pedido := TPedido.Create;
  Pedidos := TMapPedidos.Create(con, 'pedidos');
  VControle := FormatDateTime('yyyymmddhhnnzz', Now);
  try
    Pedido.Cliente    := edCliente.Tag;
    Pedido.Data       := deDataPedido.Date;
    Pedido.Desconto   := StrToCurr(edDesconto.Caption);
    Pedido.Subtotal   := StrToCurr(edSubtotal.Caption);
    Pedido.Vendedor   := dm.Tag;
    Pedido.Observacao := VControle;

    Pedidos.Nulls := True;
    Pedidos.Table.IgnoredFields.CommaText := 'imposto_fonte,status,pagamento';
    Pedidos.Add(Pedido);
    Pedidos.Apply;

    Pedido.Observacao := VControle;
    Pedidos.Find(Pedido, 'observacao=:observacao');
    Result := Pedido.Id;
  finally
    Pedido.Free;
    Pedidos.Free;
  end;
end;

procedure TfrmVendas.SubtotalizaItem(ARow: Integer);
var
  VSubtotal, VTotal: Currency;
begin
  VSubtotal := (gridVenda.Cells[3, ARow].to_f * gridVenda.Cells[4, ARow].to_f);
  VTotal := (VSubtotal - gridVenda.Cells[6, ARow].to_f);
  gridVenda.Cells[5, ARow] := VSubtotal.to_m;
  gridVenda.Cells[7, ARow] := VTotal.to_m;
  SubtotalizaPedido;
end;

procedure TfrmVendas.SubtotalizaPedido;
var
  VSubtotal, VDesconto: Currency;
  i: Integer;
begin
  if (gridVenda.RowCount <= 1) then Exit;
  VSubtotal := 0;
  VDesconto := 0;
  for i:=1 to gridVenda.RowCount - 1 do
  begin
    if (gridVenda.Cells[9, i] <> 'deletado') then
    begin
      VSubtotal := VSubtotal + gridVenda.Cells[5,i].to_f;
      VDesconto := VDesconto + gridVenda.Cells[6,i].to_f;
    end;
  end;
  edSubtotal.Caption := VSubtotal.to_m;
  edDesconto.Caption := VDesconto.to_m;
  edTotal.Caption    := Money(VSubtotal - VDesconto);
end;

procedure TfrmVendas.ClearPedido;
begin
  edCliente.Tag        := 0;
  edCliente.Caption    := '';
  edSubtotal.Caption   := '';
  edDesconto.Caption   := '';
  edTotal.Caption      := '';
  edNF.Caption         := '';
  edEndereco.Caption   := '';
  edCelular.Caption    := '';
  edTelefone.Caption   := '';
  edCpfCnpj.Caption    := '';
  deDataPedido.Date    := Date;
  deDataPedido.Tag     := 0;
  gridVenda.RowCount   := 1;
  tbVenda.Tag          := 0; {=== Novo pedido ===}
end;

procedure TfrmVendas.RegistraItem(RowGrid, AIdPedido: Integer);
begin
  RegistraItem(RowGrid, RowGrid, AIdPedido);
end;

procedure TfrmVendas.RegistraItem(Sequencia, RowGrid, AIdPedido: Integer);
var
  Item: TItemPedido;
  Itens: TMapItensPedido;
begin
  Item := TItemPedido.Create;
  Itens := TMapItensPedido.Create(con, 'itens_pedidos');
  try
    Item.Pedido             := AIdPedido;
    Item.Sequencia          := Sequencia;
    Item.Quantidade         := gridVenda.Cells[3, RowGrid].to_f;
    Item.Valor              := gridVenda.Cells[4, RowGrid].to_f;
    Item.Desconto           := gridVenda.Cells[6, RowGrid].to_f;
    Item.Produto            := gridVenda.Cells[8, RowGrid].to_i;
    Item.Status             := ifthen(tbVenda.Tag=2, 'C', 'A');
    Itens.Add(Item);
    Itens.Apply;
  finally
    Item.Free;
    Itens.Free;
  end;
end;

procedure TfrmVendas.DeletarItem(aRow: Integer);
begin
  if MessageDlg('Deletar Item', 'Tem certeza que deseja EXCLUIR ' + LineEnding +
          'esse item do pedido?', mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then
  begin
    if (tbVenda.Tag = 0) then
    begin
      gridVenda.DeleteRow(aRow);
    end
    else
    begin
      gridVenda.Cells[9, aRow] := 'deletado';
      gridVenda.Refresh;
    end;
    gridVenda.Tag := 1;
    SubtotalizaPedido;
  end;
end;

procedure TfrmVendas.Cancelar;
begin
  if tbLista.Showing then Close;
  tbLista.Show;
end;

procedure TfrmVendas.CarregarPedidos;
var
  query: TdSQLdbQuery;
  i: Integer;
  VCliente: IGetCliente;
  Pedido: TPedido;
  VStatus, VOrdem: String;
begin
  Pedido := TPedido.Create;
  query := TdSQLdbQuery.Create(con);
  case rgStatus.ItemIndex of
    0: VStatus := '1=1';
    1: VStatus := 'status=''A''';
    2: VStatus := 'status=''F''';
    3: VStatus := 'status=''C''';
  end;
  VOrdem := ifthen(rgOrdem.ItemIndex = 0, 'asc', 'desc');
  query.SQL.Text := 'select * from pedidos where ('+VStatus+') and (data between :dStart and :dEnd) order by data '+VOrdem+', id '+VOrdem;
  query.Params[0].AsDateTime := deStart.Date;
  query.Params[1].AsDateTime := deEnd.Date;
  try
    query.Open;
    if not query.IsEmpty then
    begin
      gridLista.RowCount := query.RowsAffected + 1;
      query.First;
      for i := 1 to query.RowsAffected do
      begin
        dUtils.dGetFields(Pedido, query.Fields);
        gridLista.TagCell[0, i] := Pedido.Id;
        gridLista.Cells[0, i]   := Pedido.Id.to_s;
        gridLista.Cells[1, i]   := Pedido.Data.to_s;
        //gridLista.Cells[2, i]   := Pedido.Data_emissao.to_s;
        VCliente := TGetCliente.new(Pedido.Cliente);
        gridLista.Cells[3, i]   := VCliente.nome;
        gridLista.Cells[4, i]   := VCliente.cpf_cnpj.maskCpfCnpj;
        gridLista.Cells[5, i]   := Money(Pedido.Subtotal - Pedido.Desconto);
        gridLista.Cells[6, i]   := Pedido.Status;
        gridLista.TagCell[6, i] := AnsiIndexStr(Trim(Pedido.Status), ['A', 'C', 'F']);
        query.Next;
      end;
    end
    else
      gridLista.RowCount := 1;
  finally
    query.Free;
    Pedido.Free;
  end;
end;

function TfrmVendas.Salvar(AStatus: String): Integer;
var
  VIdPedido, i: Integer;
begin
  Result := 0;
  {=== Verifica se existem itens para efetuara venda ===}
  if gridVenda.RowCount < 2 then Exit;

  {=== Se for condicional, obriga a ter cliente definido ===}
  if ((AStatus='C') and (edCliente.Tag = 0)) then
  begin
    ShowMessage('Para fazer condicional, é necessário definir um cliente!');
    btnDefineCliente.SetFocus;
    Abort;
  end;

  {=== Caso seja pedido novo, cria o pedido e registra os itens ===}
  if (tbVenda.Tag = 0) then
  begin
    {=== Cria o registro na tabela pedidos e pega o id ===}
    VIdPedido := RegistraPedido;
    if (VIdPedido < 1) then Exit;
    for i:=1 to gridVenda.RowCount -1 do
      RegistraItem(i, VIdPedido);

    if (AStatus = 'C') then ModificarPedido(VIdPedido, 'C');
    //else if (AStatus = 'F') then
    //  ModificarPedido(VIdPedido, 'F');
  end
  else
  begin
    VIdPedido := edNF.Caption.to_i;
    {=== Verifica se houve alterações no pedido ===}
    if VerificaAlteracoesNoPedido(AStatus) then
    begin
      if MessageDlg('Deseja salvar as alterações feitas nesse pedido?',
        mtWarning, [mbYes, mbNo], 0, mbNo) <> mrYes then Exit;
      {=== Faz as alterações devidas... ===}
      ConciliaAlteracoes(VIdPedido, AStatus);
    end;
  end;

  {=== Preencher Impostos ===}


  Result := VIdPedido;
end;

procedure TfrmVendas.search(AScript: String);
var
  qry: TdSQLdbQuery;
  Produto: TProduto;
  i: Integer;
  q: Int64;
begin
  qry := TdSQLdbQuery.Create(con);
  Produto := TProduto.Create;
  qry.SQL.Text := AScript;
  try
    qry.Open;
    if not qry.IsEmpty then
    begin
      gridSearch.RowCount := qry.RowsAffected + 1;
      qry.First;
      for i := 1 to qry.RowsAffected do
      begin
        dUtils.dGetFields(Produto, qry.Fields);
        gridSearch.TagCell[0, i] := Produto.Id;
        gridSearch.Cells[0, i] := Produto.Id.to_s;
        gridSearch.Cells[1, i] := Produto.Descricao;
        gridSearch.Cells[2, i] := Produto.Estoque.to_s;
        gridSearch.Cells[3, i] := Produto.Preco_venda.to_m;
        qry.Next;
      end;
      q := qry.RowsAffected;
      lbRodapeSearch.Caption := IfThen(q>1, Format('%d produtos encontrados', [q]), 'Um produto encontrado');
    end
    else
    begin
      gridSearch.RowCount := 1;
      lbRodapeSearch.Caption := 'Nenhum produto encontrado';
    end;
  finally
    Produto.Free;
    qry.Free;
  end;
end;

procedure TfrmVendas.searchDefault;
begin
  Search('select id, descricao, estoque, preco_venda from produtos where id>0 order by id desc');
end;

procedure TfrmVendas.DefinirCliente;
begin
  edCliente.Tag := createFormGetTag(TfrmBuscaCliente, frmBuscaCliente);
  if edCliente.Tag = 0 then Exit;
  PreencherCliente;
end;

procedure TfrmVendas.CarregarDetalhes(AId: Integer);
var
  Pedido: TPedido;
  Pedidos: TMapPedidos;
  VCliente: IGetCliente;
  Item: TItemPedido;
  query: TdSQLdbQuery;
  i: Integer;
  VProduto: IGetProduto;
const
  AFormPagto: array[0..6] of String = ('À Vista','A prazo','Cartão de crédito (rotativo)','Cartão de crédito (parcelado)','Cartão de débito','Credipar','Cheque');
begin
  tbDetails.Show;
  Pedido := TPedido.Create;
  Pedidos := TMapPedidos.Create(con, 'Pedidos');
  try
    Pedido.Id := AId;
    Pedidos.Get(Pedido);
    VCliente := TGetCliente.new(Pedido.Cliente);
    fRz.Caption        := VCliente.nome;
    fcpf_cnpj.Caption  := VCliente.cpf_cnpj.maskCpfCnpj;
    fDtEmissao.Caption := Pedido.Data.to_s;
//    fDtpedido.Caption := Pedido.Data_entrada.to_s;
    fVenda.Caption     := Pedido.Id.to_s;
    fFormaPgto.Caption := AFormPagto[Pedido.Pagamento];
    fSubtotal.Caption  := Pedido.Subtotal.to_m;
    fDesconto.Caption  := Pedido.Desconto.to_m;
    fTotal.Caption     := Money(Pedido.Subtotal - Pedido.Desconto);
  finally
    Pedido.Free;
    Pedidos.Free;
  end;
  Item := TItemPedido.Create;
  query := TdSQLdbQuery.Create(con);
  query.SQL.Text := 'select * from itens_pedidos where pedido=:pedido';
  query.Param('pedido').AsInteger := AId;
  try
    query.Open;
    if not query.IsEmpty then
    begin
      gridDetails.RowCount := query.RowsAffected + 1;
      query.First;
      for i := 1 to query.RowsAffected do
      begin
        dUtils.dGetFields(Item, query.Fields);
        VProduto := TGetProduto.new(Item.Produto);
        gridDetails.Cells[0, i] := Item.Sequencia.to_s;
        gridDetails.Cells[1, i] := Item.Produto.to_s;
        gridDetails.Cells[2, i] := VProduto.ean13;
        gridDetails.Cells[3, i] := VProduto.referencia;
        gridDetails.Cells[4, i] := VProduto.descricao;
        gridDetails.Cells[5, i] := Item.Quantidade.to_s;
        gridDetails.Cells[6, i] := Item.Valor.to_m;
        gridDetails.Cells[7, i] := Item.Desconto.to_m;
        gridDetails.Cells[8, i] := Money(Item.Quantidade * Item.Valor - Item.Desconto);
        query.Next;
      end;
    end;
  finally
    query.Free;
    Item.Free;
  end;
end;

procedure TfrmVendas.ReabrirPedido(AId: Integer);
var
  Pedido: TPedido;
  Pedidos: TMapPedidos;
  Item: TItemPedido;
  VProduto: IGetProduto;
  i: Integer;
  query: TdSQLdbQuery;
begin
  ClearPedido;
  Pedido := TPedido.Create;
  Pedidos := TMapPedidos.Create(con, 'Pedidos');
  try
    Pedido.Id := AId;
    Pedidos.Get(Pedido);
    edCliente.Tag := Pedido.Cliente;
    PreencherCliente;
    {=== Status do pedido reaberto ===}
    tbVenda.Tag := 1 + AnsiIndexStr(Trim(Pedido.Status.up), ['A', 'C', 'F']);

    deDataPedido.Date      := Pedido.Data;
    edNF.Caption           := Pedido.Id.to_s;

    //fDtpedido.Caption := Pedido.Data_entrada.to_s;
  finally
    Pedido.Free;
    Pedidos.Free;
  end;
  Item := TItemPedido.Create;
  query := TdSQLdbQuery.Create(con);
  query.SQL.Text := 'select * from itens_pedidos where pedido=:pedido';
  query.Param('pedido').AsInteger := AId;
  try
    query.Open;
    if not query.IsEmpty then
    begin
      gridVenda.RowCount := query.RowsAffected + 1;
      query.First;
      for i := 1 to query.RowsAffected do
      begin
        dUtils.dGetFields(Item, query.Fields);
        VProduto := TGetProduto.new(Item.Produto);
        gridVenda.TagCell[0, i] := Item.Id;
        gridVenda.Cells[0, i] := i.to_s;
        gridVenda.Cells[1, i] := VProduto.referencia;
        gridVenda.Cells[2, i] := VProduto.descricao;
        gridVenda.Cells[3, i] := Item.Quantidade.to_s;
        gridVenda.Cells[4, i] := Item.Valor.to_m;
        gridVenda.Cells[6, i] := Item.Desconto.to_m;
        gridVenda.Cells[8, i] := VProduto.id.to_s;
        SubtotalizaItem(i);
        query.Next;
      end;
    end;
  finally
    tbVenda.Show;
    query.Free;
    Item.Free;
  end;
end;

procedure TfrmVendas.ConciliaAlteracoes(AId: Integer; AStatus: String);
var
  i, j: Integer;
  VStatus: String;
begin
  j := 0;
  for i:=1 to gridVenda.RowCount -1 do
  begin
    VStatus := gridVenda.Cells[9, i].down;
    if (VStatus <> 'deletado') then j := j + i;
    if (gridVenda.TagCell[0, i] = 0) then
      RegistraItem(j, i, AId)
    else
    case AnsiIndexStr(VStatus, ['deletado', 'modificado', '']) of
      0: TGetItemPedido.new(gridVenda.TagCell[0, i]).remove;
      1: TGetItemPedido.new(gridVenda.TagCell[0, i]).atualiza(
         j, gridVenda.Cells[3, i].to_f, gridVenda.Cells[4, i].to_f,
         gridVenda.Cells[6, i].to_f
      );
    end;
  end;
  ModificarPedido(AId, AStatus);
end;

procedure TfrmVendas.ModificarPedido(AId: Integer; AStatus: String);
var
  Pedido: TPedido;
  Pedidos: TMapPedidos;
begin
  Pedido  := TPedido.Create;
  Pedidos := TMapPedidos.Create(con, 'pedidos');
  try
    Pedido.Id := AId;
    Pedidos.Get(Pedido);
    Pedido.Status := AStatus;
    Pedido.Desconto := edDesconto.Caption.to_f;
    Pedido.Subtotal := edSubtotal.Caption.to_f;
    Pedido.Data     := deDataPedido.Date;
    Pedido.Cliente  := edCliente.Tag;
    Pedidos.Modify(Pedido);
    Pedidos.Apply;
  finally
    Pedido.Free;
    Pedidos.Free;
  end;
end;

function TfrmVendas.VerificaAlteracoesNoPedido(AStatus: String): Boolean;
var
  i: Integer;
  VAlterado: Boolean;
begin
  VAlterado := False;
  VAlterado := ((edCliente.Tag <> 0) and (TGetPedido.new(edNF.Caption.to_i).cliente <> edCliente.Tag));
  if (gridVenda.RowCount>1) then
  begin
    for i:=1 to gridVenda.RowCount -1 do
    begin
      VAlterado := (gridVenda.Cells[9, i] <> '') or (gridVenda.TagCell[0, i] = 0);
      if VAlterado then Break;
    end;
  end;
  Result := (VAlterado) or (AStatus <> 'A') or (deDataPedido.Tag <> 0);
end;

end.
