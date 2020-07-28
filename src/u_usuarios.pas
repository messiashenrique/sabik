unit u_usuarios;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, ComCtrls, ActnList, u_models, dSQLdbBroker,
  u_libs, pingrid, strutils, dUtils, Grids;

{ TfrmUsuarios }

type
  TKindMsg = (kdSucess, kdAlert, kdNotify, kdError);

  TfrmUsuarios = class(TForm)
    btnNew: TBitBtn;
    btnAdd: TBitBtn;
    btnCancel: TBitBtn;
    btnEdit: TBitBtn;
    btnRemove: TBitBtn;
    btnSave: TBitBtn;
    edEmail: TEdit;
    edLogin: TEdit;
    edNome: TEdit;
    edSearch: TEdit;
    grid: TPinGrid;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    imgl: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lbTitulo: TLabel;
    lbCod: TLabel;
    nbCrud: TNotebook;
    pnDetails: TPanel;
    pnMsg: TPanel;
    pgDetails: TPage;
    pgGrid: TPage;
    pnControles: TPanel;
    pnRotulo: TPanel;
    pnTop: TPanel;
    rgNivel: TRadioGroup;
    sb: TStatusBar;
    Timer: TTimer;
    procedure btnAddClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure gridDblClick(Sender: TObject);
    procedure gridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect;
      aState: TGridDrawState);
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
    function Validates: Boolean;
  public
    { public declarations }
  end;

var
  frmUsuarios: TfrmUsuarios;

implementation

{$R *.lfm}

{ TfrmUsuarios }

procedure TfrmUsuarios.btnNewClick(Sender: TObject);
begin
  AddRegister;
end;

procedure TfrmUsuarios.btnAddClick(Sender: TObject);
begin
  AddRegister;
end;

procedure TfrmUsuarios.btnCancelClick(Sender: TObject);
begin
  CancelRegister;
end;

procedure TfrmUsuarios.btnEditClick(Sender: TObject);
begin
  EditRegister;
end;

procedure TfrmUsuarios.btnRemoveClick(Sender: TObject);
begin
  RemoveRegister;
end;

procedure TfrmUsuarios.btnSaveClick(Sender: TObject);
begin
  SaveRegister;
end;

procedure TfrmUsuarios.edSearchChange(Sender: TObject);
var
  p: String;
begin
  p := '''%'+edSearch.Text+'%''';
  if (Length(edSearch.Text) > 0) then
    Search('select id, nome, email, nivel from usuarios where (id>0) and '+
           '((nome like '+p+') or (email like '+p+') or (id like '+p+'))')
  else
    SearchDefault;
end;

procedure TfrmUsuarios.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key = 40) or (Key = 13)) and (grid.RowCount > 1) then grid.SetFocus;
end;

procedure TfrmUsuarios.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 114) then SetSearch;      {===F3===}
  if (key = 116) then AddRegister;    {===F5===}
  if (key = 117) then EditRegister;   {===F6===}
  if (key = 119) then RemoveRegister; {===F8===}
  if (key = 121) then SaveRegister;   {===F10===}
  if (key = 27)  then CancelRegister; {===Esc===}
end;

procedure TfrmUsuarios.FormShow(Sender: TObject);
begin
  SearchDefault;
  edSearch.SetFocus;
end;

procedure TfrmUsuarios.gridDblClick(Sender: TObject);
begin
  if (grid.RowCount > 1) and (grid.Row > 0) then
  begin
    pgDetails.Tag := grid.TagCell[0, grid.Row];
    pgDetails.Show;
  end;
end;

procedure TfrmUsuarios.gridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (aRow>0) and (aCol=3) then
  begin
    case grid.TagCell[3, aRow] of
      0: grid.Canvas.TextOut(aRect.Left+3, aRect.Top+2, 'ADMINISTRADOR');
      1: grid.Canvas.TextOut(aRect.Left+3, aRect.Top+2, 'GERENTE');
      2: grid.Canvas.TextOut(aRect.Left+3, aRect.Top+2, 'CAIXA');
      3: grid.Canvas.TextOut(aRect.Left+3, aRect.Top+2, 'VENDEDOR');
    end;

  end;
end;

procedure TfrmUsuarios.gridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 13) and (grid.RowCount > 1) and (grid.Row > 0) then
  begin
    pgDetails.Tag := grid.TagCell[0, grid.Row];
    pgDetails.Show;
  end;
end;

procedure TfrmUsuarios.pgDetailsBeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
var
  Usuarios: TMapUsuarios;
  Usuario: TUsuario;
begin
  if (pgDetails.Tag > 0) then
  begin
    Usuarios := TMapUsuarios.Create(con, 'USUARIOS');
    Usuario := TUsuario.Create;
    try
      Usuario.Id := pgDetails.Tag;
      if Usuarios.Get(Usuario) then
      begin
        lbCod.Caption     := Usuario.Id.to_s;
        edNome.Text       := Usuario.Nome;
        edLogin.Text      := Usuario.Login;
        edEmail.Text      := Usuario.Email;
        rgNivel.ItemIndex := Usuario.Nivel;
      end;
    finally
      Usuario.Free;
      Usuarios.Free;
    end;
    setControls;
  end
    else clearFields;
end;

procedure TfrmUsuarios.pgGridBeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
begin
  searchDefault;
end;

procedure TfrmUsuarios.sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  if (Panel.Index = 0) then imgl.Draw(sb.Canvas, Rect.Left, Rect.Top, 5);
end;

procedure TfrmUsuarios.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  pnMsg.Hide;
end;

procedure TfrmUsuarios.clearFields;
begin
  {=== Limpa os controles que estiverem em pgDetails ===}
  edNome.Clear;
  edLogin.Clear;
  edEmail.Clear;
  rgNivel.ItemIndex := 3;
  lbCod.Caption := '';
end;

procedure TfrmUsuarios.GoBackToGrid;
begin
  setControls;
  pgGrid.Show;
  edSearch.SetFocus;
end;

procedure TfrmUsuarios.Search(AScript: String);
var
  i: Integer;
  qry: TdSQLdbQuery;
  Usuario: TUsuario;
begin
  qry := TdSQLdbQuery.Create(con);
    Usuario := TUsuario.Create;
    qry.SQL.Text := AScript;
    try
      qry.Open;
      if not qry.IsEmpty then
      begin
        grid.RowCount := qry.RowsAffected + 1;
        qry.First;
        for i := 1 to qry.RowsAffected do
        begin
          dUtils.dGetFields(Usuario, qry.Fields);
          grid.TagCell[0, i] := Usuario.Id;
          grid.Cells[0, i] := Usuario.Id.to_s;
          grid.Cells[1, i] := Usuario.Nome;
          grid.Cells[2, i] := Usuario.Email;
          grid.TagCell[3, i] := Usuario.Nivel;
          qry.Next;
        end;
      end
      else
        grid.RowCount := 1;
    finally
      Usuario.Free;
      qry.Free;
    end;
end;

procedure TfrmUsuarios.SearchDefault;
begin
  {=== Faz uma busca padrão ===}
  Search('select id, nome, email, nivel from usuarios where id>0');
end;

procedure TfrmUsuarios.SetControls(AOpen: Boolean);
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

function TfrmUsuarios.Validates: Boolean;
var
  VConteudo: String;
begin
  Result := False;
  VConteudo := Trim(edLogin.Text);
  if (VConteudo <> '') then
  begin
    if (Length(VConteudo) <> Length(VConteudo.raw)) then
      Flash('Não use caracteres especiais para o "Nome de usuário"', kdError)
    else if (Pos(' ', VConteudo) > 0) then
      Flash('O "Nome de usuário" não pode conter espaços', kdError)
    else Result := True;
  end
  else
    Flash('O campo "Nome de usuário" não pode ficar em branco', kdError);
  if not Result then edLogin.SetFocus;
end;

procedure TfrmUsuarios.AddRegister;
begin
  if nbCrud.Tag = 1 then Exit;
  if not pgDetails.Showing then
  begin
    pgDetails.Tag := 0;
    pgDetails.Show;
    setControls(True);
    edNome.SetFocus;
  end;
end;

procedure TfrmUsuarios.EditRegister;
begin
  if (nbCrud.Tag = 1) and (not pgDetails.Showing) then Exit;
  setControls(True);
  edNome.SetFocus;
end;

procedure TfrmUsuarios.RemoveRegister;
var
  Usuario: TUsuario;
  Usuarios: TMapUsuarios;
begin
  if (nbCrud.Tag = 1) or (pgDetails.Tag = 0) then Exit;
  if MessageDlg('Tem certeza que deseja excluir esse usuário?', mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then
  begin
    Usuario := TUsuario.Create;
    Usuarios :=TMapUsuarios.Create(con, 'USUARIOS');
    try
      Usuario.Id := pgDetails.Tag;
      Usuarios.Remove(Usuario);
      Usuarios.Apply;
    finally
      Usuario.Free;
      Usuarios.Free;
    end;
    GoBackToGrid;
    Flash('Usuário removido com sucesso!');
  end;
end;

procedure TfrmUsuarios.SaveRegister;
var
  Usuario: TUsuario;
  Usuarios: TMapUsuarios;
begin
  if (nbCrud.Tag= 0) then Exit;
  {=== Faz as validações ===}
  if not Validates then Exit;
  Usuario := TUsuario.Create;
  Usuarios := TMapUsuarios.Create(u_models.con, 'USUARIOS');
  try
    Usuario.Nome := edNome.Text;
    Usuario.Login := edLogin.Text;
    Usuario.Email := edEmail.Text;
    Usuario.Nivel := rgNivel.ItemIndex;
    Usuarios.Nulls := True;
    Usuarios.Table.IgnoredFields.Add('senha');
    if (pgDetails.Tag > 0) then
    begin
      Usuario.Id := pgDetails.Tag;
      Usuarios.Modify(Usuario);
    end
    else
      Usuarios.Add(Usuario);
    try
      Usuarios.Apply;
    except
      Flash('Houve um erro!', kdError);
      Usuarios.Rollback;
    end;
  finally
    Usuario.Free;
    Usuarios.Free;
  end;
  GoBackToGrid;
  Flash(IfThen((pgDetails.Tag>0), 'Usuário modificado com sucesso', 'Usuário cadastrado com sucesso!'));
end;

procedure TfrmUsuarios.CancelRegister;
begin
  if pgGrid.Showing then
    Close
  else
  begin
    GoBackToGrid;
    Flash('Operação cancelada.', kdNotify);
  end;
end;

procedure TfrmUsuarios.SetSearch;
begin
  if pgGrid.Showing then edSearch.SetFocus;
end;

procedure TfrmUsuarios.Flash(AMessage: String; AkdMsg: TKindMsg);
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

