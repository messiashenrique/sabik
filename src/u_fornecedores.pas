unit u_fornecedores;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, ComCtrls, ActnList, ghSQL, dSQLdbBroker,
  u_models, u_libs, pingrid, strutils, dUtils;

{ TfrmFornecedores }

type
  TKindMsg = (kdSucess, kdAlert, kdNotify, kdError);

  TfrmFornecedores = class(TForm)
    btnNew: TBitBtn;
    btnAdd: TBitBtn;
    btnCancel: TBitBtn;
    btnEdit: TBitBtn;
    btnRemove: TBitBtn;
    btnSave: TBitBtn;
    edBairro: TEdit;
    edCelular: TEdit;
    edCep: TEdit;
    edCidade: TEdit;
    edCnpj: TEdit;
    edEmail: TEdit;
    edEndereco: TEdit;
    edFax: TEdit;
    edIe: TEdit;
    edNome: TEdit;
    edRepresentante: TEdit;
    edRz: TEdit;
    edSearch: TEdit;
    edTelefone: TEdit;
    edUF: TEdit;
    grid: TPinGrid;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    imgl: TImageList;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lbTitulo: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbCod: TLabel;
    lbDataCadastro: TLabel;
    mmObs: TMemo;
    nbCrud: TNotebook;
    pnDetails: TPanel;
    pnMsg: TPanel;
    pgDetails: TPage;
    pgGrid: TPage;
    pnControles: TPanel;
    pnRotulo: TPanel;
    pnTop: TPanel;
    sb: TStatusBar;
    Timer: TTimer;
    procedure btnAddClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure edCelularExit(Sender: TObject);
    procedure edCepExit(Sender: TObject);
    procedure edCnpjExit(Sender: TObject);
    procedure edFaxExit(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edTelefoneExit(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure gridDblClick(Sender: TObject);
    procedure gridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure pgDetailsBeforeShow({%H-}ASender: TObject; {%H-}ANewPage: TPage;
      {%H-}ANewIndex: Integer);
    procedure pgGridBeforeShow({%H-}ASender: TObject; {%H-}ANewPage: TPage;
      {%H-}ANewIndex: Integer);
    procedure sbDrawPanel({%H-}StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure TimerTimer(Sender: TObject);
  private
    procedure clearFields; virtual;
    procedure GoBackToGrid;
    procedure Search(AScript: String);
    procedure SearchDefault; virtual;
    procedure SetControls(AOpen: Boolean = False); virtual;
    procedure AddRegister;
    procedure EditRegister;
    procedure RemoveRegister;
    procedure SaveRegister;
    procedure CancelRegister;
    procedure SetSearch;
    procedure Flash(AMessage: String; AkdMsg: TKindMsg = kdSucess);
  public
    { public declarations }
  end;

var
  frmFornecedores: TfrmFornecedores;

implementation

{$R *.lfm}

{ TfrmFornecedores }

procedure TfrmFornecedores.btnNewClick(Sender: TObject);
begin
  AddRegister;
end;

procedure TfrmFornecedores.btnAddClick(Sender: TObject);
begin
  AddRegister;
end;

procedure TfrmFornecedores.btnCancelClick(Sender: TObject);
begin
  CancelRegister;
end;

procedure TfrmFornecedores.btnEditClick(Sender: TObject);
begin
  EditRegister;
end;

procedure TfrmFornecedores.btnRemoveClick(Sender: TObject);
begin
  RemoveRegister;
end;

procedure TfrmFornecedores.btnSaveClick(Sender: TObject);
begin
  SaveRegister;
end;

procedure TfrmFornecedores.edCelularExit(Sender: TObject);
begin
  edCelular.Text := edCelular.Text.maskPhone;
end;

procedure TfrmFornecedores.edCepExit(Sender: TObject);
begin
  edCep.Text := edCep.Text.maskCep;
end;

procedure TfrmFornecedores.edCnpjExit(Sender: TObject);
begin
  edCnpj.Text := edCnpj.Text.maskCpfCnpj;
end;

procedure TfrmFornecedores.edFaxExit(Sender: TObject);
begin
  edFax.Text := edFax.Text.maskPhone;
end;

procedure TfrmFornecedores.edSearchChange(Sender: TObject);
var
  p: String;
begin
  p := '''%'+edSearch.Text+'%''';
  if (Length(edSearch.Text) > 0) then
    Search('select id, nome, razao, cnpj, cidade, telefone from fornecedores '+
           'where (id>0) and ((nome like '+p+') or (razao like '+p+') or '+
           '(id like '+p+') or (cnpj like '+p+'))')
  else
    SearchDefault;
end;

procedure TfrmFornecedores.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key = 40) or (Key = 13)) and (grid.RowCount > 1) then grid.SetFocus;
end;

procedure TfrmFornecedores.edTelefoneExit(Sender: TObject);
begin
  edTelefone.Text := edTelefone.Text.maskPhone;
end;

procedure TfrmFornecedores.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 114) then SetSearch;      {===F3===}
  if (key = 116) then AddRegister;    {===F5===}
  if (key = 117) then EditRegister;   {===F6===}
  if (key = 119) then RemoveRegister; {===F8===}
  if (key = 121) then SaveRegister;   {===F10===}
  if (key = 27)  then CancelRegister; {===Esc===}
end;

procedure TfrmFornecedores.FormShow(Sender: TObject);
begin
  SearchDefault;
  edSearch.SetFocus;
end;

procedure TfrmFornecedores.gridDblClick(Sender: TObject);
begin
  if (grid.RowCount > 1) and (grid.Row > 0) then
  begin
    pgDetails.Tag := grid.TagCell[0, grid.Row];
    pgDetails.Show;
  end;
end;

procedure TfrmFornecedores.gridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 13) and (grid.RowCount > 1) and (grid.Row > 0) then
  begin
    pgDetails.Tag := grid.TagCell[0, grid.Row];
    pgDetails.Show;
  end;
end;

procedure TfrmFornecedores.pgDetailsBeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
var
  Fornecedores: TMapFornecedores;
  Fornecedor: TFornecedor;
begin
  if (pgDetails.Tag > 0) then
  begin
    Fornecedores := TMapFornecedores.Create(con, 'FORNECEDORES');
    Fornecedor := TFornecedor.Create;
    try
      Fornecedor.Id := pgDetails.Tag;
      if Fornecedores.Get(Fornecedor) then
      begin
        lbCod.Caption           := Fornecedor.Id.to_s;
        lbDataCadastro.Caption  := Fornecedor.Data_cad.to_s;
        edCnpj.Text             := Fornecedor.Cnpj.maskCpfCnpj;
        edIe.Text               := Fornecedor.Ie;
        edNome.Text             := Fornecedor.Nome;
        edRz.Text               := Fornecedor.Razao;
        edEndereco.Text         := Fornecedor.Endereco;
        edBairro.Text           := Fornecedor.Bairro;
        edCep.Text              := Fornecedor.Cep.maskCep;
        edCidade.Text           := Fornecedor.Cidade;
        edUF.Text               := Fornecedor.Uf;
        edTelefone.Text         := Fornecedor.Telefone.maskPhone;
        edFax.Text              := Fornecedor.Fax.maskPhone;
        edRepresentante.Text    := Fornecedor.Representante;
        edCelular.Text          := Fornecedor.Celular.maskCellPone;
        edEmail.Text            := Fornecedor.Email;
        mmObs.Text              := Fornecedor.Observacao;
      end;
    finally
      Fornecedor.Free;
      Fornecedores.Free;
    end;
    setControls;
  end
    else clearFields;
end;

procedure TfrmFornecedores.pgGridBeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
begin
  searchDefault;
end;

procedure TfrmFornecedores.sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  if (Panel.Index = 0) then imgl.Draw(sb.Canvas, Rect.Left, Rect.Top, 5);
end;

procedure TfrmFornecedores.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  pnMsg.Hide;
end;

procedure TfrmFornecedores.clearFields;
begin
  {=== Limpa os controles que estiverem em pgDetails ===}
  lbCod.Caption := '';
  lbDataCadastro.Caption := '';
  edCnpj.Clear;
  edIe.Clear;
  edNome.Clear;
  edRz.Clear;
  edEndereco.Clear;
  edBairro.Clear;
  edCep.Clear;
  edCidade.Clear;
  edUF.Clear;
  edTelefone.Clear;
  edFax.Clear;
  edRepresentante.Clear;
  edCelular.Clear;
  edEmail.Clear;
  mmObs.Clear;
end;

procedure TfrmFornecedores.GoBackToGrid;
begin
  setControls;
  pgGrid.Show;
  edSearch.SetFocus;
end;

procedure TfrmFornecedores.Search(AScript: String);
var
  i: Integer;
  qry: TdSQLdbQuery;
  Fornecedor: TFornecedor;
begin
  qry := TdSQLdbQuery.Create(con);
    Fornecedor := TFornecedor.Create;
    qry.SQL.Text := AScript;
    try
      qry.Open;
      if not qry.IsEmpty then
      begin
        grid.RowCount := qry.RowsAffected + 1;
        qry.First;
        for i := 1 to qry.RowsAffected do
        begin
          dUtils.dGetFields(Fornecedor, qry.Fields);
          grid.TagCell[0, i] := Fornecedor.Id;
          grid.Cells[0, i] := Fornecedor.Id.to_s;
          grid.Cells[1, i] := IfThen((Fornecedor.Nome=''), Fornecedor.Razao, Fornecedor.Nome);
          grid.Cells[2, i] := Fornecedor.Cnpj.maskCpfCnpj;
          grid.Cells[3, i] := Fornecedor.Cidade;
          grid.Cells[4, i] := Fornecedor.Telefone.maskPhone;
          qry.Next;
        end;
      end
      else
        grid.RowCount := 1;
    finally
      Fornecedor.Free;
      qry.Free;
    end;
end;

procedure TfrmFornecedores.SearchDefault;
begin
  {=== Faz uma busca padrão ===}
  Search('select id, nome, razao, cnpj, cidade, telefone from fornecedores where id>0');
end;

procedure TfrmFornecedores.SetControls(AOpen: Boolean);
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

procedure TfrmFornecedores.AddRegister;
begin
  if nbCrud.Tag = 1 then Exit;
  if not pgDetails.Showing then
  begin
    pgDetails.Tag := 0;
    pgDetails.Show;
    setControls(True);
    edCnpj.SetFocus;
  end;
end;

procedure TfrmFornecedores.EditRegister;
begin
  if (nbCrud.Tag = 1) and (not pgDetails.Showing) then Exit;
  setControls(True);
  edCnpj.SetFocus;
end;

procedure TfrmFornecedores.RemoveRegister;
var
  Fornecedor: TFornecedor;
  Fornecedores: TMapFornecedores;
begin
  if (nbCrud.Tag = 1) or (pgDetails.Tag = 0) then Exit;
  if MessageDlg('Tem certeza que deseja excluir esse fornecedor?', mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then
  begin
    Fornecedor := TFornecedor.Create;
    Fornecedores :=TMapFornecedores.Create(con, 'FORNECEDORES');
    try
      Fornecedor.Id := pgDetails.Tag;
      Fornecedores.Remove(Fornecedor);
      Fornecedores.Apply;
    finally
      Fornecedor.Free;
      Fornecedores.Free;
    end;
    GoBackToGrid;
    Flash('Fornecedor removido com sucesso!');
  end;
end;

procedure TfrmFornecedores.SaveRegister;
var
  Fornecedor: TFornecedor;
  Fornecedores: TMapFornecedores;
begin
  if (nbCrud.Tag= 0) then Exit;
  {=== Faz as validações ===}
  Fornecedor := TFornecedor.Create;
  Fornecedores := TMapFornecedores.Create(u_models.con, 'FORNECEDORES');
  try
    Fornecedor.Cnpj           := edCnpj.Text.raw_numbers;
    Fornecedor.Ie             := edIe.Text.raw_numbers;
    Fornecedor.Nome           := edNome.Text.raw;
    Fornecedor.Razao          := edRz.Text.raw;
    Fornecedor.Endereco       := edEndereco.Text.raw;
    Fornecedor.Bairro         := edBairro.Text.raw;
    Fornecedor.Cep            := edCep.Text.raw_numbers;
    Fornecedor.Cidade         := edCidade.Text.raw;
    Fornecedor.Uf             := edUF.Text.raw;
    Fornecedor.Telefone       := edTelefone.Text.raw_numbers;
    Fornecedor.Fax            := edFax.Text.raw_numbers;
    Fornecedor.Representante  := edRepresentante.Text.raw;
    Fornecedor.Celular        := edCelular.Text.raw_numbers;
    Fornecedor.Email          := edEmail.Text.raw;
    Fornecedor.Observacao     := mmObs.Text.raw;
    Fornecedores.Nulls := True;
    Fornecedores.Table.IgnoredFields.Add('data_cad');
    if (pgDetails.Tag > 0) then
    begin
      Fornecedor.Id := pgDetails.Tag;
      Fornecedores.Modify(Fornecedor);
    end
    else
      Fornecedores.Add(Fornecedor);
    Fornecedores.Apply;
  finally
    Fornecedor.Free;
    Fornecedores.Free;
  end;
  GoBackToGrid;
  Flash(IfThen((pgDetails.Tag>0), 'Fornecedor modificado com sucesso', 'Fornecedor cadastrado com sucesso!'));
end;

procedure TfrmFornecedores.CancelRegister;
begin
  if pgGrid.Showing then
    Close
  else
  begin
    GoBackToGrid;
    Flash('Operação cancelada.', kdNotify);
  end;
end;

procedure TfrmFornecedores.SetSearch;
begin
  if pgGrid.Showing then edSearch.SetFocus;
end;

procedure TfrmFornecedores.Flash(AMessage: String; AkdMsg: TKindMsg);
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
    end;
  end;
  pnMsg.Caption := AMessage;
  pnMsg.Show;
  Timer.Enabled := True;
end;

end.

