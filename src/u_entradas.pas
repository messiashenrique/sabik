unit u_entradas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, Menus, u_libs, u_models, u_rules, u_busca_grupo, u_dm,
  u_busca_produto, ACBrNFe, ACBrNFeDANFeRLClass, pingrid, strutils, Types, math,
  Grids, Buttons, EditBtn, dSQLdbBroker, dUtils;

type

  { TfrmEntradas }

  TfrmEntradas = class(TForm)
    btnCancel: TBitBtn;
    btnNew: TBitBtn;
    btnSave: TBitBtn;
    cbTribut: TComboBox;
    Danfe: TACBrNFeDANFeRL;
    deEntrada: TDateEdit;
    edChaveNFe: TLabel;
    edCnpj: TLabel;
    edIE: TLabel;
    edNF: TLabel;
    edRz: TLabel;
    edSearch: TEdit;
    edTotal: TLabel;
    fChaveNFe: TLabel;
    fCNPJ: TLabel;
    fDtEmissao: TLabel;
    fDtEntrada: TLabel;
    fNF: TLabel;
    fRz: TLabel;
    fTotal: TLabel;
    gridEntradas: TPinGrid;
    gridDetails: TPinGrid;
    gridLista: TPinGrid;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    img16: TImageList;
    imlEntries: TImageList;
    lbChave1: TLabel;
    lbCNPJ1: TLabel;
    lbDataEmi: TLabel;
    lbDtEmi1: TLabel;
    lbDtEnt1: TLabel;
    lbFornecedor1: TLabel;
    labell: TLabel;
    lbNF1: TLabel;
    lbTitulo: TLabel;
    lbChave: TLabel;
    lbCNPJ: TLabel;
    lbDtEmi: TLabel;
    lbDtEnt: TLabel;
    lbFornecedor: TLabel;
    lbNF: TLabel;
    lbIE: TLabel;
    lbTitulo1: TLabel;
    lbTotal: TLabel;
    lbTotal1: TLabel;
    menuGrid: TPopupMenu;
    mnDelete: TMenuItem;
    mnShowDanfe: TMenuItem;
    mnShowDetails: TMenuItem;
    nfe: TACBrNFe;
    pg: TPageControl;
    pnDetails1: TPanel;
    pnListaTop: TPanel;
    pnEntradasTop: TPanel;
    pnTopDetails: TPanel;
    sb: TStatusBar;
    tbLista: TTabSheet;
    tbEntradas: TTabSheet;
    tbDetails: TTabSheet;
    procedure btnCancelClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure cbTributExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure gridEntradasDblClick(Sender: TObject);
    procedure gridEntradasDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure gridEntradasKeyPress(Sender: TObject; var Key: char);
    procedure gridEntradasMouseMove(Sender: TObject; {%H-}Shift: TShiftState; X,
      Y: Integer);
    procedure gridEntradasSelectCell(Sender: TObject; aCol, aRow: Integer;
      var {%H-}CanSelect: Boolean);
    procedure gridEntradasValidateEntry({%H-}sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
    procedure gridListaDblClick(Sender: TObject);
    procedure gridListaMouseUp(Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
    procedure mnDeleteClick(Sender: TObject);
    procedure mnShowDanfeClick(Sender: TObject);
    procedure mnShowDetailsClick(Sender: TObject);
    procedure sbDrawPanel({%H-}StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure tbDetailsShow(Sender: TObject);
    procedure tbListaShow(Sender: TObject);
  private
    procedure AddNFe;
    function RegisterVendors: Integer;
    function RegisterEntry(AIdVendor: Integer): Integer;
    function RegistraProduto(RowGrid: Integer): Integer;
    procedure RegistraItem(RowGrid, AIdEntrada, AIdProduto: Integer);
    procedure GetNFe;
    procedure DeletarItemNFe(var aRow: Integer);
    procedure VincularDesvincular(ARow: Integer);
    procedure Cancelar;
    procedure CarregarNFes;
    procedure Salvar;
    procedure RemoverEntrada(AId: Integer);
    procedure CarregarDetalhes(AId: Integer);
    procedure GerarDanfe(AID: Integer);
    {private declarations}
  public
    {public declarations}
  end;

var
  frmEntradas: TfrmEntradas;

implementation

{$R *.lfm}

{ TfrmEntradas }

procedure TfrmEntradas.btnNewClick(Sender: TObject);
begin
  AddNFe;
end;

procedure TfrmEntradas.btnCancelClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TfrmEntradas.btnSaveClick(Sender: TObject);
begin
  Salvar;
end;

procedure TfrmEntradas.cbTributExit(Sender: TObject);
begin
  gridEntradas.Cells[gridEntradas.Col, gridEntradas.Row] := cbTribut.Items[cbTribut.ItemIndex];
  cbTribut.Visible := False;
  gridEntradas.TagCell[5, gridEntradas.Row] := cbTribut.ItemIndex;
  gridEntradas.SetFocus;
end;

procedure TfrmEntradas.FormCreate(Sender: TObject);
begin
  pg.ShowTabs := False;
end;

procedure TfrmEntradas.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //if (key = 114) then SetSearch;      {===F3===}
  if (key = 116) then AddNFe;    {===F5===}
  //if (key = 117) then EditRegister;   {===F6===}
  //if (key = 119) then RemoverEntrada; {===F8===}
  if (key = 121) then Salvar;   {===F10===}
  if (key = 27)  then Cancelar; {===Esc===}
end;

procedure TfrmEntradas.FormShow(Sender: TObject);
begin
  edSearch.SetFocus;
end;

procedure TfrmEntradas.gridEntradasDblClick(Sender: TObject);
var
  aCol, aRow, VGrupo: Integer;
  R: Classes.TRect;
begin
  aCol := gridEntradas.Col;
  aRow := gridEntradas.Row;
  if gridEntradas.Row = 0 then Exit;
  case aCol of
    {=== Chama o formulário de produtos e carrega o resultado no grid ===}
    1: begin
      VGrupo := createFormGetTag(TfrmBuscaGrupo, frmBuscaGrupo);
      if not VGrupo > 0 then
        VGrupo := TGetInfo.new.grupo_padrao;
      gridEntradas.TagCell[1, aRow] := VGrupo;
      gridEntradas.Cells[1, aRow] := TGetGrupo.new(VGrupo).nome;
    end;

    5: begin
      {=== Chama o combobox para escolher o tipo de tributação ===}
      R := gridEntradas.CellRect(aCol, aRow);
      R.Left := R.Left + gridEntradas.Left;
      R.Right := R.Right + gridEntradas.Left;
      R.Top := R.Top + gridEntradas.Top;
      R.Bottom := R.Bottom + gridEntradas.Top;
      cbTribut.Left := R.Left;
      cbTribut.Top := R.Top;
      cbTribut.Width := (R.Right) - R.Left;
      cbTribut.Height := (R.Bottom) - R.Top;
      cbTribut.Visible := True;
      cbTribut.SetFocus;
      cbTribut.Show;
      cbTribut.ItemIndex := gridEntradas.TagCell[5, gridEntradas.Row];
    end;

      {=== Vincula ou desvincula produtos (novo ou reposição) ===}
      10: VincularDesvincular(aRow);
    end;
end;

procedure TfrmEntradas.gridEntradasDrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  S: String;
begin
  if aRow = 0 then Exit;
  S := gridEntradas.Cells[aCol, aRow];

  if (gdSelected in aState) then gridEntradas.Canvas.Brush.Color := $00D8EAFE;
  gridEntradas.Canvas.FillRect(aRect);

  case aCol of
    {=== Pinta os ícones e específica o tipo de tributação do item ===}
    5: begin
      case gridEntradas.TagCell[5, aRow] of
        0: S := 'Tributado';
        1: S := 'Isento';
        2: S := 'Não Incid.';
        3: S := 'Subst. Trib.';
      end;
      gridEntradas.Canvas.TextRect(aRect, aRect.Left + 21, aRect.Top, S);
      img16.Draw(gridEntradas.Canvas, aRect.Left + 1, aRect.Top + 1, gridEntradas.TagCell[5, aRow]);
    end;
    {=== Pinta icone e informa a coluna status com "Novo" ou "Reposição" ===}
    10: begin
      if gridEntradas.TagCell[0, aRow] > 0 then S := 'Repos.' else S := 'Novo';
      gridEntradas.Canvas.TextRect(aRect, aRect.Left + 19, aRect.Top, S);
      img16.Draw(gridEntradas.Canvas, aRect.Left + 1, aRect.Top + 1, ifthen(gridEntradas.TagCell[0, aRow]=0, 2, 4));
    end;
  else
    gridEntradas.Canvas.TextRect(aRect, aRect.Left, aRect.Top, S);
  end;
end;

procedure TfrmEntradas.gridEntradasKeyPress(Sender: TObject; var Key: char);
var
  aCol, aRow: Integer;
begin
  aCol := gridEntradas.Col;
  aRow := gridEntradas.Row;
  {=== Trata a entrada de teclas na coluna da tributação ===}
  if Key = #13 then Exit;
  {=== Tratar cada coluna em particular ===}
  case aCol of
    0: if UpperCase(Key) = 'X' then DeletarItemNFe(aRow);

    1, 2: Key := OnlyKeyNumbers(Key);

    5: begin
      case UpperCase(Key) of
        'T': gridEntradas.TagCell[aCol, aRow] := 0;
        'I': gridEntradas.TagCell[aCol, aRow] := 1;
        'N': gridEntradas.TagCell[aCol, aRow] := 2;
        'S', 'F': gridEntradas.TagCell[aCol, aRow] := 3;
      end;
      gridEntradas.Invalidate;
      Key := #0;
    end;

    6, 7, 8: Key := OnlyKeyMoney(Key);

    10: if UpperCase(Key) = 'V' then VincularDesvincular(aRow);
  end;
end;

procedure TfrmEntradas.gridEntradasMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  C, R: Longint;
begin
  Initialize(C);
  Initialize(R);
  gridEntradas.MouseToCell(X, Y, C, R);
  if gridEntradas.Mark[C, R] then
    case C of
      2: Hint := 'Código de barras inválido!';
      4: Hint := 'Esse campo não pode ficar em branco.';
    end
  else
    Hint := gridEntradas.Cells[C, R];
end;

procedure TfrmEntradas.gridEntradasSelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
var
  S, S_error: String;
begin
  case aCol of
    0: S := 'Pressione "X" para excluir o item | Esc-Para voltar';
    1: S := 'Para alterar o grupo, dê um duplo clique ou, se preferir, digite o código de um grupo e tecle ENTER.';
    2: S := 'Para modificar, basta digitar o número do código de barras';
    3: S := 'Caso queira modificar, digite algum código de referência.';
    4: S := 'Digite uma nova descrição caso queira alterar esta.';
    5: S := 'Digite "T" para Tributado, "I" para Isento, "N" para Não Incidente e "F" para Substituição Tributária.';
    6: S := 'Para modificar, basta digitar um novo valor.';
    7: S := 'Digite um novo valor caso queira alterar este.';
    8: S := 'Para modificar, basta digitar uma nova quantidade.';
    9: S := 'Caso queira modificar, basta digitar a nova unidade de medida.';
    10: S := 'Digite "V" para vincular ou desvincular a um produto já existente em estoque.';
  end;

  case aCol of
    2: S_error := 'Código de barras inválido! Por favor, verifique.';
    4: S_error := 'O campo "Descrição" não pode ficar em branco';
    7: S_error := 'O valor de venda não pode ser inferior ao valor de compra';
  end;
  sb.Panels[0].Text := 'Dica:';
  sb.Panels[1].Text := S;
  sb.Panels[2].Text := ifthen(gridEntradas.Mark[aCol, aRow], 'Erro:', '');
  sb.Panels[3].Text := IfThen(gridEntradas.Mark[aCol, aRow], S_error, '');
end;

procedure TfrmEntradas.gridEntradasValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
begin
  if (aRow = 0) then Exit;
  case aCol of
    1: TGetGrupo.New(NewValue.to_i).writeInCell(gridEntradas, aCol, aRow);
    2: gridEntradas.Mark[aCol, aRow] := not BasicValidateEAN13(NewValue);
    4: begin
      NewValue := UpperCase(NewValue);
      gridEntradas.Mark[aCol, aRow] := (Length(NewValue.raw)=0);
    end;
    3, 9: NewValue := UpperCase(NewValue);
    6: begin
      gridEntradas.Mark[aCol, aRow] := NewValue.to_f <= 0;
      NewValue := NewValue.to_m;
    end;
    7: begin
      gridEntradas.Mark[aCol, aRow] := NewValue.to_f < gridEntradas.Cells[6, aRow].to_f;
      if NewValue.to_f <> OldValue.to_f then
        gridEntradas.Cells[12, aRow] := FloatToStr(round(((gridEntradas.Cells[7, aRow].to_f / gridEntradas.Cells[6, aRow].to_f)*100)-100));
      NewValue := NewValue.to_m;
    end;
  end;
end;

procedure TfrmEntradas.gridListaDblClick(Sender: TObject);
begin
  if (gridLista.RowCount>1) then
    CarregarDetalhes(gridLista.TagCell[0, gridLista.Row]);
end;

procedure TfrmEntradas.gridListaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ((Button = mbRight) and (gridLista.RowCount > 1)) then
    menuGrid.PopUp;
end;

procedure TfrmEntradas.mnDeleteClick(Sender: TObject);
begin
  if MessageDlg('Atenção',
    'Tem certeza que deseja remover essa Entrada de mercadorias?', mtWarning,
    [mbNo, mbYes], 0, mbNo) <> mrYes then
      Exit;
  if gridLista.RowCount < 2 then Exit;
  try
    RemoverEntrada(gridLista.TagCell[0, gridLista.Row]);
  finally
    CarregarNFes;
  end;
end;

procedure TfrmEntradas.mnShowDanfeClick(Sender: TObject);
begin
  if gridLista.RowCount < 2 then Exit;
  GerarDanfe(gridLista.TagCell[0, gridLista.Row]);
end;

procedure TfrmEntradas.mnShowDetailsClick(Sender: TObject);
begin
  if gridLista.RowCount < 2 then Exit;
  CarregarDetalhes(gridLista.TagCell[0, gridLista.Row]);
end;

procedure TfrmEntradas.sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
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

procedure TfrmEntradas.tbDetailsShow(Sender: TObject);
begin
  sb.Panels[0].Text := 'Dica:';
  sb.Panels[1].Text := 'Esc-Para voltar';
  sb.Panels[2].Text := '';
  sb.Panels[3].Text := '';
  gridDetails.SetFocus;
end;

procedure TfrmEntradas.tbListaShow(Sender: TObject);
begin
  sb.Panels[0].Text := 'Dica:';
  sb.Panels[1].Text := 'F5-Para cadastrar nova nota | Esc-Para sair';
  sb.Panels[2].Text := '';
  sb.Panels[3].Text := '';
  CarregarNFes;
  edSearch.SetFocus;
end;

procedure TfrmEntradas.AddNFe;
var
  VExiste: Boolean;
  Entradas: TMapEntradas;
  Entrada: TEntrada;
  VXMLFile: String;
  VOd: TOpenDialog;
begin
  if not tbLista.Showing then Exit;
  VOd := TOpenDialog.Create(nil);
  VOd.DefaultExt := '*.xml';
  VOd.Filter := '*.xml';
  VOd.InitialDir := GetUserDir + PathDelim + 'desktop';
  try
    VOd.Execute;
    VXMLFile := VOd.FileName;
  finally
    VOd.Free;
  end;
    if VXMLFile = '' then Exit;
  try
    {===Valida o carregamento do XML (se é realmente uma NFe) ===}
    nfe.NotasFiscais.Clear;
    if not nfe.NotasFiscais.LoadFromFile(VXMLFile) then
    begin
      {=== chama msg de erro ===}
      MessageDlg('Arquivo XML inválido!', mtError, [mbOK], 0);
      Abort;
    end;
    Entrada := TEntrada.Create;
    Entradas := TMapEntradas.Create(con, 'entradas');
    Entrada.Chave_nfe := nfe.NotasFiscais.Items[0].NFe.procNFe.chNFe;
    VExiste :=  Entradas.Get(Entrada);
  finally
    Entrada.Free;
    Entradas.Free;
  end;
  if VExiste then
    MessageDlg('NFe já Cadastrada!', 'Esta NFe já está cadastrada no '
      +'sistema!', mtError, [mbOK], 0)
  else
    GetNFe;
end;

procedure TfrmEntradas.GetNFe;
begin
  tbEntradas.Show;
  with nfe.NotasFiscais.Items[0] do
  begin
    edRz.Caption        := IfThen(NFe.Emit.xNome = '', NFe.Emit.xFant, NFe.Emit.xNome);
    edCnpj.Caption      := NFe.Emit.CNPJCPF.maskCpfCnpj;
    edIE.Caption        := NFe.Emit.IE;
    edNF.Caption        := NFe.Ide.nNF.to_s;
    edChaveNFe.Caption  := NFe.procNFe.chNFe;
    edTotal.Caption     := NFe.Total.ICMSTot.vNF.to_m;
    lbDataEmi.Caption   := NFe.Ide.dEmi.to_s;
    deEntrada.Date      := Date;
    TItemNFe.New(NFe).showInGrid(gridEntradas);
  end;
end;

function TfrmEntradas.RegisterVendors: Integer;
var
  Fornecedores: TMapFornecedores;
  Fornecedor: TFornecedor;
begin
  Fornecedor := TFornecedor.Create;
  Fornecedores := TMapFornecedores.Create(con, 'fornecedores');
  Fornecedor.Cnpj := nfe.NotasFiscais.Items[0].NFe.Emit.CNPJCPF.raw_numbers;
  try
    if not Fornecedores.Find(Fornecedor, 'cnpj=:cnpj') then
      with nfe.NotasFiscais.Items[0].NFe.Emit do
      begin
        Fornecedor.Data_cad      := Date;
        Fornecedor.Razao         := xNome.raw.up;
        Fornecedor.Nome          := ifthen(xFant='', xNome.raw.up, xFant.raw.up);
        Fornecedor.Ie            := IE;
        Fornecedor.Endereco      := ifthen(EnderEmit.nro='', EnderEmit.xLgr.raw.up, EnderEmit.xLgr.raw+', '+EnderEmit.nro);
        Fornecedor.Bairro        := EnderEmit.xBairro.raw.up;
        Fornecedor.Cep           := EnderEmit.CEP.to_s;
        Fornecedor.Cidade        := EnderEmit.xMun.raw.up;
        Fornecedor.Uf            := EnderEmit.UF.up;
        Fornecedor.Telefone      := EnderEmit.fone.raw_numbers;
        Fornecedores.Add(Fornecedor);
        Fornecedores.Apply;

        Fornecedor.Cnpj := CNPJCPF.raw_numbers;
        Fornecedores.Find(Fornecedor, 'cnpj=:cnpj');
      end;
    Result := Fornecedor.Id;
  finally
    Fornecedor.Free;
    Fornecedores.Free;
  end;
end;

function TfrmEntradas.RegisterEntry(AIdVendor: Integer): Integer;
var
  Entrada: TEntrada;
  Entradas: TMapEntradas;
begin
  Entrada  := TEntrada.Create;
  Entradas := TMapEntradas.Create(con, 'entradas');
  try
    with nfe.NotasFiscais.Items[0].NFe do
    begin
      Entrada.Fornecedor       := AIdVendor;
      Entrada.Nf               := Ide.nNF.to_s;
      Entrada.Chave_nfe        := procNFe.chNFe;
      Entrada.Data_emissao     := Ide.dEmi;
      Entrada.Data_entrada     := deEntrada.Date;
      Entrada.Usuario          := dm.Tag; //1
      Entrada.Subtotal         := Total.ICMSTot.vNF;

      Entradas.Add(Entrada);
      Entradas.Apply;

      Entrada.Chave_nfe := procNFe.chNFe;
    end;
    Entradas.Find(Entrada, 'chave_nfe=:chave_nfe');
    Result := Entrada.Id;
  finally
    Entrada.Free;
    Entradas.Free;
  end;
end;

function TfrmEntradas.RegistraProduto(RowGrid: Integer): Integer;
var
  VIdProduto: NativeInt;
  Produto: TProduto;
  Produtos: TMapProdutos;
  VNovo: Boolean;
  query: TdSQLdbQuery;
begin
  Produto  := TProduto.Create;
  Produtos := TMapProdutos.Create(con, 'produtos');
  try
    VNovo := (gridEntradas.TagCell[0, RowGrid] = 0);
    if VNovo then
    begin
      Produto.Data_cad      := Date;
      Produto.Balanco       := 1;   { TODO -oMessias : Provisoriamente }
      Produto.Preco_compra  := gridEntradas.Cells[6, RowGrid].to_f;
      Produto.Ean13         := gridEntradas.Cells[2, RowGrid].raw_numbers;
    end
    else
    begin
      VIdProduto             := gridEntradas.TagCell[0, RowGrid];
      Produto.id             := VIdProduto;
      Produtos.Get(Produto);
      if (Produto.Preco_compra < gridEntradas.Cells[6, RowGrid].to_f) then
        Produto.Preco_compra := gridEntradas.Cells[6, RowGrid].to_f;
    end;
    Produto.Grupo            := gridEntradas.TagCell[1, RowGrid];
    if Length(gridEntradas.Cells[11, RowGrid]) < 8 then
      Produto.Ncm            := TGetGrupo.new(gridEntradas.TagCell[1, RowGrid]).ncm
    else
      Produto.Ncm            := gridEntradas.Cells[11, RowGrid].raw_numbers;
    Produto.Referencia       := gridEntradas.Cells[3, RowGrid];
    Produto.Descricao        := gridEntradas.Cells[4, RowGrid].raw;
    Produto.Unidade          := gridEntradas.Cells[9, RowGrid].raw;
    case gridEntradas.TagCell[5, RowGrid] of
      0: Produto.Tributacao  := 'T';
      1: Produto.Tributacao  := 'I';
      2: Produto.Tributacao  := 'N';
      3: Produto.Tributacao  := 'F';
    end;
    Produto.Aliquota         := 17;
    Produto.Preco_venda      := gridEntradas.Cells[7, RowGrid].to_f;
    Produto.Margem           := gridEntradas.Cells[12, RowGrid].to_f;
    Produto.Cest             := Trim(gridEntradas.Cells[13, RowGrid]);
    Produto.Data_ult_compra  := Date;
    Produtos.Nulls := True;
    Produtos.Table.IgnoredFields.Add('ativo');
    if VNovo then
      Produtos.Add(Produto)
    else
      Produtos.Modify(Produto);
    Produtos.Apply;
    if VNovo then
    begin
      query := TdSQLdbQuery.Create(con);
      query.SQL.Text := 'select first 1 id from produtos order by id desc';
      try
        query.Open;
        query.GetFields(Produto);
        VIdProduto := Produto.Id;
      finally
        query.Free;
      end;
    end;
  finally
    Result := VIdProduto;
    Produto.Free;
    Produtos.Free;
  end;
end;

procedure TfrmEntradas.RegistraItem(RowGrid, AIdEntrada, AIdProduto: Integer);
var
  Item: TItemEntrada;
  Itens: TMapItensEntrada;
begin
  Item := TItemEntrada.Create;
  Itens := TMapItensEntrada.Create(con, 'itens_entradas');
  try
    Item.Entrada            := AIdEntrada;
    Item.Produto            := AIdProduto;
    Item.Sequencia          := gridEntradas.Cells[0, RowGrid].to_i;
    Item.Quantidade         := gridEntradas.Cells[8, RowGrid].to_f;
    Item.Valor              := gridEntradas.Cells[6, RowGrid].to_f;
    Item.Preco              := gridEntradas.Cells[7, RowGrid].to_f;
    Itens.Add(Item);
    Itens.Apply;
  finally
    Item.Free;
    Itens.Free;
  end;
end;

procedure TfrmEntradas.DeletarItemNFe(var aRow: Integer);
begin
  if MessageDlg('Deletar Item', 'Tem certeza que deseja EXCLUIR ' + LineEnding +
          'esse item da Nota Fiscal?', mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then
  begin
    gridEntradas.DeleteRow(aRow);
  end;
end;

procedure TfrmEntradas.VincularDesvincular(ARow: Integer);
begin
  if gridEntradas.TagCell[0, ARow] > 0 then
  begin
    if MessageDlg('Desvincular Produto', 'Gostaria de desvincular o '
      +'produto?' + LineEnding + 'Isto é, cadastrá-lo como novo '
        +'produto?', mtWarning, [mbYes, mbCancel], 0) = mrYes then
    begin
      gridEntradas.TagCell[0, aRow] := 0;
      gridEntradas.TagCell[2, aRow] := 0;
      gridEntradas.TagCell[3, aRow] := 0;
    end;
  end
  else
  begin
    if MessageDlg('Vincular Produto', 'Gostaria de vincular o item a um '
      +'produto já existente?' + LineEnding + 'Isto é, cadastrá-lo '
        +'como reposição?', mtWarning, [mbYes, mbCancel], 0) = mrYes
          then
    begin
      TGetProduto.new(createFormGetTag(TfrmBuscaProduto, frmBuscaProduto)
      ).writeInCell(gridEntradas, ARow);
      //TVinculadoInCell.New(createFormGetTag(TfrmSearchProduct,
      //  frmSearchProduct)
      //).Write(gridEntradas, 1, ARow);
    end;
  end;
end;

procedure TfrmEntradas.Cancelar;
begin
  if tbLista.Showing then Close;
  tbLista.Show;
end;

procedure TfrmEntradas.CarregarNFes;
var
  query: TdSQLdbQuery;
  Entrada: TEntrada;
  i: Integer;
  VFornecedor: IGetFornecedor;
begin
  Entrada := TEntrada.Create;
  query := TdSQLdbQuery.Create(con);
  query.SQL.Text := 'select first 50 * from entradas order by id desc';
  try
    query.Open;
    if not query.IsEmpty then
    begin
      gridLista.RowCount := query.RowsAffected + 1;
      query.First;
      for i := 1 to query.RowsAffected do
      begin
        dUtils.dGetFields(Entrada, query.Fields);
        gridLista.TagCell[0, i] := Entrada.Id;
        gridLista.Cells[0, i]   := Entrada.Id.to_s;
        gridLista.Cells[1, i]   := Entrada.Data_entrada.to_s;
        gridLista.Cells[2, i]   := Entrada.Data_emissao.to_s;
        VFornecedor := TGetFornecedor.new(Entrada.Fornecedor);
        gridLista.Cells[3, i]   := VFornecedor.nome;
        gridLista.Cells[4, i]   := VFornecedor.cnpj.maskCpfCnpj;
        gridLista.Cells[5, i]   := Entrada.Nf;
        gridLista.Cells[6, i]   := Entrada.Subtotal.to_m;
        query.Next;
      end;
    end
    else
      gridLista.RowCount := 1;
  finally
    query.Free;
    Entrada.Free;
  end;
end;

procedure TfrmEntradas.Salvar;
var
  VIdFornecedor, VIdEntrada, VIdProduto, i: Integer;
  VFile: String;
begin
  if not tbEntradas.Showing then Exit;

  if MessageDlg('Cadastrar NFe', 'Tenha certeza de que as informações estão ' +
      'corretas.' + LineEnding + 'Os dados já estão revisados e prontos?' +
      LineEnding + '', mtConfirmation, mbYesNo, 0) = mrYes then
  begin

    VIdFornecedor := RegisterVendors;
    VIdEntrada    := RegisterEntry(VIdFornecedor);

    for i := 1 to gridEntradas.RowCount - 1 do
    begin
      VIdProduto := RegistraProduto(i);
      RegistraItem(i, VIdEntrada, VIdProduto);
    end;

    VFile := nfe.NotasFiscais.Items[0].NomeArq;
    CopyFile(PChar(VFile), PChar(ExtractFilePath(Application.ExeName) +
      PathDelim + 'nfes' + PathDelim + edChaveNFe.Caption.raw_numbers) + '-nfe.xml', True);
    DeleteFile(VFile);

    ShowMessage('Informações gravadas com sucesso!');
    tbLista.Show;
  end;
end;

procedure TfrmEntradas.RemoverEntrada(AId: Integer);
var
  Entrada: TEntrada;
  Entradas: TMapEntradas;
begin
  Entrada := TEntrada.Create;
  Entradas := TMapEntradas.Create(con, 'entradas');
  try
    Entrada.Id := AId;
    if Entradas.Get(Entrada) then
    begin
      Entradas.Remove(Entrada);
      Entradas.Apply;
    end;
  finally
    Entradas.Free;
    Entrada.Free;
  end;
end;

procedure TfrmEntradas.CarregarDetalhes(AId: Integer);
var
  Entrada: TEntrada;
  Entradas: TMapEntradas;
  VFornecedor: IGetFornecedor;
  Item: TItemEntrada;
  query: TdSQLdbQuery;
  i: Integer;
  VProduto: IGetProduto;
begin
  tbDetails.Show;
  Entrada := TEntrada.Create;
  Entradas := TMapEntradas.Create(con, 'entradas');
  try
    Entrada.Id := AId;
    Entradas.Get(Entrada);
    VFornecedor := TGetFornecedor.new(Entrada.Fornecedor);
    fRz.Caption        := VFornecedor.nome;
    fCNPJ.Caption      := VFornecedor.cnpj.maskCpfCnpj;
    fDtEmissao.Caption := Entrada.Data_emissao.to_s;
    fDtEntrada.Caption := Entrada.Data_entrada.to_s;
    fNF.Caption        := Entrada.Nf;
    fChaveNFe.Caption  := Entrada.Chave_nfe;
    fTotal.Caption     := Entrada.Subtotal.to_m;
  finally
    Entrada.Free;
    Entradas.Free;
  end;
  Item := TItemEntrada.Create;
  query := TdSQLdbQuery.Create(con);
  query.SQL.Text := 'select * from itens_entradas where entrada=:entrada';
  query.Param('entrada').AsInteger := AId;
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
        gridDetails.Cells[7, i] := Item.Preco.to_m;
        query.Next;
      end;
    end;
  finally
    query.Free;
    Item.Free;
  end;
end;

procedure TfrmEntradas.GerarDanfe(AID: Integer);
var
  Entrada: TEntrada;
  Entradas: TMapEntradas;
  VXmlFile: String;
begin
  Entrada := TEntrada.Create;
  Entradas := TMapEntradas.Create(con, 'entradas');
  try
    Entrada.Id := AId;
    if Entradas.Get(Entrada) then
    begin
      VXmlFile := Application.Location + 'nfes' + PathDelim + Entrada.Chave_nfe + '-nfe.xml';
      nfe.NotasFiscais.Clear;
      nfe.NotasFiscais.LoadFromFile(VXmlFile);
      nfe.DANFE.ImprimirDANFE;
    end;
  finally
    Entradas.Free;
    Entrada.Free;
  end;
end;

end.
