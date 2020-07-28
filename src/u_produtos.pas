unit u_produtos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, ComCtrls, ActnList, Spin, ghSQL, dSQLdbBroker,
  u_models, u_libs, u_rules, u_busca_grupo, pingrid, strutils, dUtils;

{ TfrmProdutos }

type
  TKindMsg = (kdSucess, kdAlert, kdNotify, kdError);

  TfrmProdutos = class(TForm)
    btnNew: TBitBtn;
    btnAdd: TBitBtn;
    btnCancel: TBitBtn;
    btnEdit: TBitBtn;
    btnRemove: TBitBtn;
    btnSave: TBitBtn;
    btnSearchGroup: TBitBtn;
    cbUnidade: TComboBox;
    edCompra: TEdit;
    edDescricao: TEdit;
    edEan13: TEdit;
    edEstoque: TEdit;
    edEstoqueminimo: TEdit;
    edGrupo: TEdit;
    edMarca: TEdit;
    edNcm: TEdit;
    edCest: TEdit;
    edReferencia: TEdit;
    edSearch: TEdit;
    edVendaAvista: TEdit;
    edVendaAprazo: TEdit;
    grid: TPinGrid;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    imgl: TImageList;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbCod: TLabel;
    lbDataCadastro: TLabel;
    lbDataUltimaCompra: TLabel;
    lbTitulo: TLabel;
    mmObs: TMemo;
    nbCrud: TNotebook;
    pnDetails: TPanel;
    pnMsg: TPanel;
    pgDetails: TPage;
    pgGrid: TPage;
    pnControles: TPanel;
    pnRotulo: TPanel;
    pnTop: TPanel;
    rgTrib: TRadioGroup;
    sb: TStatusBar;
    seAliquota: TSpinEdit;
    seMargemAvista: TSpinEdit;
    seMargemAprazo: TSpinEdit;
    Timer: TTimer;
    procedure btnAddClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnSearchGroupClick(Sender: TObject);
    procedure edCompraExit(Sender: TObject);
    procedure edGrupoExit(Sender: TObject);
    procedure edGrupoKeyPress(Sender: TObject; var Key: char);
    procedure edNcmExit(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edVendaAvistaExit(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure gridDblClick(Sender: TObject);
    procedure gridKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure pgDetailsBeforeShow({%H-}ASender: TObject; {%H-}ANewPage: TPage;
      {%H-}ANewIndex: Integer);
    procedure pgGridBeforeShow({%H-}ASender: TObject; {%H-}ANewPage: TPage;
      {%H-}ANewIndex: Integer);
    procedure sbDrawPanel({%H-}StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure seMargemAvistaChange(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    procedure ClearFields; virtual;
    procedure GetNomeGrupo(AId: Integer);
    procedure GoBackToGrid;
    procedure Search(AScript: String);
    procedure SearchDefault; virtual;
    procedure SetControls(AOpen: Boolean = False); virtual;
    procedure GetRegister(AId: Integer);
    procedure AddRegister;
    procedure EditRegister;
    procedure RemoveRegister;
    procedure SaveRegister;
    procedure CancelRegister;
    procedure SetSearch;
    procedure Flash(AMessage: String; AkdMsg: TKindMsg = kdSucess);
    procedure CalculaPrecoVenda;
    function Validates: Boolean;
  public
    { public declarations }
  end;

var
  frmProdutos: TfrmProdutos;

implementation

{$R *.lfm}

{ TfrmProdutos }

procedure TfrmProdutos.btnNewClick(Sender: TObject);
begin
  AddRegister;
end;

procedure TfrmProdutos.btnAddClick(Sender: TObject);
begin
  AddRegister;
end;

procedure TfrmProdutos.btnCancelClick(Sender: TObject);
begin
  CancelRegister;
end;

procedure TfrmProdutos.btnEditClick(Sender: TObject);
begin
  EditRegister;
end;

procedure TfrmProdutos.btnRemoveClick(Sender: TObject);
begin
  RemoveRegister;
end;

procedure TfrmProdutos.btnSaveClick(Sender: TObject);
begin
  SaveRegister;
end;

procedure TfrmProdutos.btnSearchGroupClick(Sender: TObject);
begin
  GetNomeGrupo(createFormGetTag(TfrmBuscaGrupo, frmBuscaGrupo));
end;

procedure TfrmProdutos.edCompraExit(Sender: TObject);
begin
  edCompra.Text := edCompra.Text.to_m;
  if edCompra.Text.to_f > 0 then
    CalculaPrecoVenda;
end;

procedure TfrmProdutos.edGrupoExit(Sender: TObject);
begin
  if ((Length(edGrupo.Text) > 0) and (edGrupo.Text.to_i > 0)) then
    GetNomeGrupo(edGrupo.Text.to_i);
end;

procedure TfrmProdutos.edGrupoKeyPress(Sender: TObject; var Key: char);
begin
  if ((Key = #13) and (Length(edGrupo.Text) > 0)) then
    GetNomeGrupo(edGrupo.Text.to_i);
end;

procedure TfrmProdutos.edNcmExit(Sender: TObject);
begin
  if ((Trim(edNcm.Text) = '') and (edGrupo.Tag > 0)) then
    edNcm.Text := TGetGrupo.new(edGrupo.Tag).ncm;
end;

procedure TfrmProdutos.edSearchChange(Sender: TObject);
var
  p: String;
begin
  p := '''%'+edSearch.Text+'%''';
  if (Length(edSearch.Text) > 0) then
    Search('select id, ean13, referencia, descricao, estoque, preco_venda from produtos '+
           'where (descricao like '+p+') or (ean13 like '+p+') or (referencia like '+
           p+') or (id like '+p+')')
  else
    SearchDefault;
end;

procedure TfrmProdutos.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key = 40) or (Key = 13)) and (grid.RowCount > 1) then grid.SetFocus;
end;

procedure TfrmProdutos.edVendaAvistaExit(Sender: TObject);
begin
  edVendaAvista.Text := edVendaAvista.Text.to_m;
end;

procedure TfrmProdutos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 114) then SetSearch;      {===F3===}
  if (key = 116) then AddRegister;    {===F5===}
  if (key = 117) then EditRegister;   {===F6===}
  if (key = 119) then RemoveRegister; {===F8===}
  if (key = 121) then SaveRegister;   {===F10===}
  if (key = 27)  then CancelRegister; {===Esc===}
end;

procedure TfrmProdutos.FormShow(Sender: TObject);
begin
  SearchDefault;
  edSearch.SetFocus;
end;

procedure TfrmProdutos.gridDblClick(Sender: TObject);
begin
  if (grid.RowCount > 1) and (grid.Row > 0) then
  begin
    pgDetails.Tag := grid.TagCell[0, grid.Row];
    pgDetails.Show;
  end;
end;

procedure TfrmProdutos.gridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 13) and (grid.RowCount > 1) and (grid.Row > 0) then
  begin
    pgDetails.Tag := grid.TagCell[0, grid.Row];
    pgDetails.Show;
  end;
end;

procedure TfrmProdutos.pgDetailsBeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
begin
  GetRegister(ANewPage.Tag);
end;

procedure TfrmProdutos.pgGridBeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
begin
  searchDefault;
end;

procedure TfrmProdutos.sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  if (Panel.Index = 0) then imgl.Draw(sb.Canvas, Rect.Left, Rect.Top, 5);
end;

procedure TfrmProdutos.seMargemAvistaChange(Sender: TObject);
begin
  if edCompra.Text.to_f > 0 then
    CalculaPrecoVenda;
end;

procedure TfrmProdutos.TimerTimer(Sender: TObject);
begin
  pnMsg.Hide;
end;

procedure TfrmProdutos.ClearFields;
begin
  {=== Limpa os control ue estiverem em pgDetails ===}
  lbCod.Caption              := '';
  lbDataCadastro.Caption     := '';
  lbDataUltimaCompra.Caption := '';
  edDescricao.Clear;
  edEan13.Clear;
  edReferencia.Clear;
  edGrupo.Clear;
  edNcm.Clear;
  seAliquota.Value := 17;
  rgTrib.ItemIndex := 0;
  edMarca.Clear;
  edEstoque.Clear;
  edEstoqueminimo.Clear;
  cbUnidade.ItemIndex := 0;
  seMargemAvista.Value := 80;  { TODO -oMessias : Pegar das configurações }
  edCompra.Clear;
  edVendaAvista.Clear;
  mmObs.Clear;
end;

procedure TfrmProdutos.GetNomeGrupo(AId: Integer);
var
  VNome: String;
begin
  VNome := TGetGrupo.new(AId).nome;
  if (VNome <> '') then
  begin
    edGrupo.Tag  := AId;
    edGrupo.Text := VNome;
    edNcm.SetFocus;
  end
  else
  begin
    edGrupo.Tag := 0;
    edGrupo.Text := 'código não localizado';
    btnSearchGroup.SetFocus;
  end;
end;

procedure TfrmProdutos.GoBackToGrid;
begin
  setControls;
  pgGrid.Show;
  edSearch.SetFocus;
end;

procedure TfrmProdutos.Search(AScript: String);
var
  i: Integer;
  qry: TdSQLdbQuery;
  Produto: TProduto;
begin
  qry := TdSQLdbQuery.Create(con);
    Produto := TProduto.Create;
    qry.SQL.Text := AScript;
    try
      qry.Open;
      if not qry.IsEmpty then
      begin
        grid.RowCount := qry.RowsAffected + 1;
        qry.First;
        for i := 1 to qry.RowsAffected do
        begin
          dUtils.dGetFields(Produto, qry.Fields);
          grid.TagCell[0, i] := Produto.Id;
          grid.Cells[0, i]   := Produto.Id.to_s;
          grid.Cells[1, i]   := Produto.Ean13;
          grid.Cells[2, i]   := Produto.Referencia;
          grid.Cells[3, i]   := Produto.Descricao;
          grid.Cells[4, i]   := Produto.Estoque.to_s;
          grid.Cells[5, i]   := Produto.Preco_venda.to_m;
          qry.Next;
        end;
      end
      else
        grid.RowCount := 1;
    finally
      Produto.Free;
      qry.Free;
    end;
end;

procedure TfrmProdutos.SearchDefault;
begin
  {=== Faz uma busca padrão ===}
  Search('select id, ean13, referencia, descricao, estoque, preco_venda from produtos order by id desc');
end;

procedure TfrmProdutos.SetControls(AOpen: Boolean);
begin
  nbCrud.Tag := ifthen(AOpen, 1, 0);
  if AOpen then
  begin
    btnAdd.Hide;
    btnEdit.Hide;
    btnRemove.Hide;
    btnSave.Show;
    btnCancel.Show;
  end
  else
  begin
    btnAdd.Show;
    btnEdit.Show;
    btnRemove.Show;
    btnSave.Hide;
    btnCancel.Hide;
  end;
end;

procedure TfrmProdutos.GetRegister(AId: Integer);
var
  Produtos: TMapProdutos;
  Produto: TProduto;
begin
  if (AId > 0) then
  begin
    Produtos := TMapProdutos.Create(con, 'produtos');
    Produto := TProduto.Create;
    try
      Produto.Id := AId;
      if Produtos.Get(Produto) then
      begin
        lbCod.Caption              := Produto.Id.to_s;
        lbDataCadastro.Caption     := Produto.Data_cad.to_s;
        lbDataUltimaCompra.Caption := Produto.Data_ult_compra.to_s;
        edDescricao.Text           := Produto.Descricao;
        edEan13.Text               := Produto.Ean13;
        edReferencia.Text          := Produto.Referencia;
        edGrupo.Tag                := Produto.Grupo;
        edGrupo.Text               := TGetGrupo.new(Produto.Grupo).nome;
        edNcm.Text                 := Produto.Ncm;
        seAliquota.Value           := Produto.Aliquota;
        rgTrib.ItemIndex           := AnsiIndexStr(Trim(Produto.Tributacao), ArrayTrib);
        edMarca.Text               := Produto.Marca;
        edEstoque.Text             := Produto.Estoque.to_s;
        edEstoqueminimo.Text       := Produto.Estoque_min.to_s;
        cbUnidade.Text             := Produto.Unidade;
        seMargemAvista.Value       := Produto.Margem_a_vista;
        seMargemAprazo.Value       := Produto.Margem_a_prazo;
        edCompra.Text              := Produto.Preco_compra.to_m;
        edVendaAvista.Text         := Produto.Preco_venda.to_m;
        edVendaAprazo.Text         := Produto.Preco_venda_a_vista;
        mmObs.Text                 := Produto.Observacao;
      end;
    finally
      Produto.Free;
      Produtos.Free;
    end;
    setControls;
  end
    else clearFields;
end;

procedure TfrmProdutos.AddRegister;
begin
  if nbCrud.Tag = 1 then Exit;
  if not pgDetails.Showing then
  begin
    pgDetails.Tag := 0;
    pgDetails.Show;
    setControls(True);
    edDescricao.SetFocus;
  end;
end;

procedure TfrmProdutos.EditRegister;
begin
  if (nbCrud.Tag = 1) and (not pgDetails.Showing) then Exit;
  setControls(True);
  edDescricao.SetFocus;
end;

procedure TfrmProdutos.RemoveRegister;
var
  Produto: TProduto;
  Produtos: TMapProdutos;
begin
  if (nbCrud.Tag = 1) or (pgDetails.Tag = 0) then Exit;
  if MessageDlg('Tem certeza que deseja excluir esse produto?', mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then
  begin
    Produto := TProduto.Create;
    Produtos :=TMapProdutos.Create(con, 'produtos');
    try
      Produto.Id := pgDetails.Tag;
      Produtos.Remove(Produto);
      Produtos.Apply;
    finally
      Produto.Free;
      Produtos.Free;
    end;
    GoBackToGrid;
    Flash('Produto removido com sucesso!');
  end;
end;

procedure TfrmProdutos.SaveRegister;
var
  Produto: TProduto;
  Produtos: TMapProdutos;
begin
  if (nbCrud.Tag= 0) then Exit;
  {=== Faz as validações ===}
  if not Validates then Exit;
  Produto := TProduto.Create;
  Produtos := TMapProdutos.Create(u_models.con, 'produtos');
  try
    Produto.Descricao     := edDescricao.Text.raw;
    Produto.Ean13         := edEan13.Text.raw_numbers;
    Produto.Referencia    := edReferencia.Text;
    Produto.Grupo         := edGrupo.Tag;
    Produto.Ncm           := edNcm.Text;
    Produto.Aliquota      := seAliquota.Value;
    Produto.Tributacao    := ArrayTrib[rgTrib.ItemIndex];
    Produto.Marca         := edMarca.Text;
    Produto.Estoque       := edEstoque.Text.to_f;
    Produto.Estoque_min   := edEstoqueminimo.Text.to_f;
    Produto.Unidade       := cbUnidade.Text;
    Produto.Margem        := seMargemAvista.Value;
    Produto.Preco_compra  := edCompra.Text.to_f;
    Produto.Preco_venda   := edVendaAvista.Text.to_f;
    Produto.Observacao    := mmObs.Text.raw;
    Produto.Balanco       := 1;    { TODO -oMessias : Provisoriamente }
    Produtos.Nulls        := True;
    Produtos.Table.IgnoredFields.CommaText :=  'data_cad,ativo';
    if (pgDetails.Tag > 0) then
    begin
      Produto.Id := pgDetails.Tag;
      Produtos.Modify(Produto);
    end
    else
    begin
      Produto.Data_ult_compra := Date;
      Produtos.Add(Produto);
    end;
    Produtos.Apply;
  finally
    Produto.Free;
    Produtos.Free;
  end;
  Flash(IfThen((pgDetails.Tag>0), 'Produto modificado com sucesso', 'Produto cadastrado com sucesso!'));
  GoBackToGrid;
end;

procedure TfrmProdutos.CancelRegister;
begin
  if pgGrid.Showing then
    Close
  else
  begin
    GoBackToGrid;
    Flash('Operação cancelada.', kdNotify);
  end;
end;

procedure TfrmProdutos.SetSearch;
begin
  if pgGrid.Showing then edSearch.SetFocus;
end;

procedure TfrmProdutos.Flash(AMessage: String; AkdMsg: TKindMsg);
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

procedure TfrmProdutos.CalculaPrecoVenda;
begin
  edVendaAvista.Text := FormatFloat('### ###,##0.00', ((1+((seMargemAvista.Value)/100))*edCompra.Text.to_f));
end;

function TfrmProdutos.Validates: Boolean;
  procedure Abortar(AMsg: String; AEdit: TEdit);
  begin
    Flash(AMsg, kdError);
    AEdit.SetFocus;
    Abort;
  end;
begin
  Result := False;
  if (Trim(edDescricao.Text) = '') then
    Abortar('O campo "Descrição" não pode ficar em branco.', edDescricao)
  else if (edGrupo.Tag < 1 ) then
    Abortar('O campo "Grupo" não pode ficar em branco.', edGrupo)
  else if (edVendaAvista.Text.to_f <= 0) then
    Abortar('O campo "Preço de venda" deve receber um valor válido.', edVendaAvista);
  Result := True;
end;

end.

