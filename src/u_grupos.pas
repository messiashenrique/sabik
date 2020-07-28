unit u_grupos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, ComCtrls, ActnList, dSQLdbBroker, u_models,
  u_libs, pingrid, strutils, dUtils, Grids, Spin;

{ TfrmGrupos }

//Const
  //ArrayTrib: Array[0..3] of String = ('T', 'I', 'N', 'F');

type
  TKindMsg = (kdSucess, kdAlert, kdNotify, kdError);

  TfrmGrupos = class(TForm)
    btnNew: TBitBtn;
    btnAdd: TBitBtn;
    btnCancel: TBitBtn;
    btnEdit: TBitBtn;
    btnRemove: TBitBtn;
    btnSave: TBitBtn;
    edNcm_padrao: TEdit;
    edNome: TEdit;
    edSearch: TEdit;
    grid: TPinGrid;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    imgl: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lbCod: TLabel;
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
    rgTributacao: TRadioGroup;
    sb: TStatusBar;
    seAliquota: TSpinEdit;
    Timer: TTimer;
    procedure btnAddClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure gridDblClick(Sender: TObject);
    procedure gridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect;
      {%H-}aState: TGridDrawState);
    procedure gridKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
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
    procedure GetRegister({%H-}AId: Integer);
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
  frmGrupos: TfrmGrupos;

implementation

{$R *.lfm}

{ TfrmGrupos }

procedure TfrmGrupos.btnNewClick(Sender: TObject);
begin
  AddRegister;
end;

procedure TfrmGrupos.btnAddClick(Sender: TObject);
begin
  AddRegister;
end;

procedure TfrmGrupos.btnCancelClick(Sender: TObject);
begin
  CancelRegister;
end;

procedure TfrmGrupos.btnEditClick(Sender: TObject);
begin
  EditRegister;
end;

procedure TfrmGrupos.btnRemoveClick(Sender: TObject);
begin
  RemoveRegister;
end;

procedure TfrmGrupos.btnSaveClick(Sender: TObject);
begin
  SaveRegister;
end;

procedure TfrmGrupos.edSearchChange(Sender: TObject);
var
  p: String;
begin
  p := '''%'+edSearch.Text.raw+'%''';
  if (Length(edSearch.Text) > 0) then
    Search('select id, nome, ncm_padrao, tributacao from grupos where'+
           '(id>0) and ((nome like '+p+') or (id like '+p+'))')
  else
    SearchDefault;
end;

procedure TfrmGrupos.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key = 40) or (Key = 13)) and (grid.RowCount > 1) then grid.SetFocus;
end;

procedure TfrmGrupos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 114) then SetSearch;      {===F3===}
  if (key = 116) then AddRegister;    {===F5===}
  if (key = 117) then EditRegister;   {===F6===}
  if (key = 119) then RemoveRegister; {===F8===}
  if (key = 121) then SaveRegister;   {===F10===}
  if (key = 27)  then CancelRegister; {===Esc===}
end;

procedure TfrmGrupos.FormShow(Sender: TObject);
begin
  SearchDefault;
  edSearch.SetFocus;
end;

procedure TfrmGrupos.gridDblClick(Sender: TObject);
begin
  if (grid.RowCount > 1) and (grid.Row > 0) then
  begin
    pgDetails.Tag := grid.TagCell[0, grid.Row];
    pgDetails.Show;
  end;
end;

procedure TfrmGrupos.gridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (aRow>0) and (aCol=3) then
  begin
    grid.Canvas.FillRect(aRect);
    case AnsiIndexStr(Trim(grid.Cells[3, aRow]), ArrayTrib) of
      0: grid.Canvas.TextOut(aRect.Left+3, aRect.Top+2, 'TRIBUTADO');
      1: grid.Canvas.TextOut(aRect.Left+3, aRect.Top+2, 'ISENTO');
      2: grid.Canvas.TextOut(aRect.Left+3, aRect.Top+2, 'NÃO INCIDENTE');
      3: grid.Canvas.TextOut(aRect.Left+3, aRect.Top+2, 'SUBST. TRIBUTÁRIA');
    end;
  end;
end;

procedure TfrmGrupos.gridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 13) and (grid.RowCount > 1) and (grid.Row > 0) then
  begin
    pgDetails.Tag := grid.TagCell[0, grid.Row];
    pgDetails.Show;
  end;
end;

procedure TfrmGrupos.pgDetailsBeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
begin
  GetRegister(ANewPage.Tag);
end;

procedure TfrmGrupos.pgGridBeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
begin
  searchDefault;
end;

procedure TfrmGrupos.sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  if (Panel.Index = 0) then imgl.Draw(sb.Canvas, Rect.Left, Rect.Top, 5);
end;

procedure TfrmGrupos.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  pnMsg.Hide;
end;

procedure TfrmGrupos.clearFields;
begin
  {=== Limpa os controles que estiverem em pgDetails ===}
  edNome.Clear;
  edNcm_padrao.Clear;
  seAliquota.Value := 17;
  rgTributacao.ItemIndex := 0;
  lbCod.Caption := '';
end;

procedure TfrmGrupos.GoBackToGrid;
begin
  setControls;
  pgGrid.Show;
  edSearch.SetFocus;
end;

procedure TfrmGrupos.Search(AScript: String);
var
  i: Integer;
  qry: TdSQLdbQuery;
  Grupo: TGrupo;
begin
  qry := TdSQLdbQuery.Create(con);
    Grupo := TGrupo.Create;
    qry.SQL.Text := AScript;
    try
      qry.Open;
      if not qry.IsEmpty then
      begin
        grid.RowCount := qry.RowsAffected + 1;
        qry.First;
        for i := 1 to qry.RowsAffected do
        begin
          dUtils.dGetFields(Grupo, qry.Fields);
          grid.TagCell[0, i] := Grupo.Id;
          grid.Cells[0, i] := Grupo.Id.to_s;
          grid.Cells[1, i] := Grupo.Nome;
          grid.Cells[2, i] := Grupo.Ncm_padrao;
          grid.Cells[3, i] := Grupo.Tributacao;
          qry.Next;
        end;
      end
      else
        grid.RowCount := 1;
    finally
      Grupo.Free;
      qry.Free;
    end;
end;

procedure TfrmGrupos.SearchDefault;
begin
  {=== Faz uma busca padrão ===}
  Search('select id, nome, ncm_padrao, tributacao from grupos where id>0');
end;

procedure TfrmGrupos.SetControls(AOpen: Boolean);
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

procedure TfrmGrupos.GetRegister(AId: Integer);
var
  Grupos: TMapGrupos;
  Grupo: TGrupo;
begin
  if (pgDetails.Tag > 0) then
  begin
    Grupos := TMapGrupos.Create(con, 'grupos');
    Grupo := TGrupo.Create;
    try
      Grupo.Id := pgDetails.Tag;
      if Grupos.Get(Grupo) then
      begin
        lbCod.Caption          := Grupo.Id.to_s;
        edNome.Text            := Grupo.Nome;
        edNcm_padrao.Text      := Grupo.Ncm_padrao;
        seAliquota.Value       := Grupo.Aliquota;
        rgTributacao.ItemIndex := AnsiIndexStr(Trim(Grupo.Tributacao), ArrayTrib);
        mmObs.Text             := Grupo.Observacao;
      end;
    finally
      Grupo.Free;
      Grupos.Free;
    end;
    setControls;
  end
    else clearFields;
end;

function TfrmGrupos.Validates: Boolean;
begin
  Result := False;
  if (edNcm_padrao.Text='') then
    Flash('O "NCM padrão" não pode ficar em branco', kdError)
  else Result := True;
  if not Result then edNcm_padrao.SetFocus;
end;

procedure TfrmGrupos.AddRegister;
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

procedure TfrmGrupos.EditRegister;
begin
  if (nbCrud.Tag = 1) and (not pgDetails.Showing) then Exit;
  setControls(True);
  edNome.SetFocus;
end;

procedure TfrmGrupos.RemoveRegister;
var
  Grupo: TGrupo;
  Grupos: TMapGrupos;
begin
  if (nbCrud.Tag = 1) or (pgDetails.Tag = 0) then Exit;
  if MessageDlg('Tem certeza que deseja excluir esse grupo?', mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then
  begin
    Grupo := TGrupo.Create;
    Grupos :=TMapGrupos.Create(con, 'grupos');
    try
      Grupo.Id := pgDetails.Tag;
      Grupos.Remove(Grupo);
      Grupos.Apply;
    finally
      Grupo.Free;
      Grupos.Free;
    end;
    GoBackToGrid;
    Flash('Grupo removido com sucesso!');
  end;
end;

procedure TfrmGrupos.SaveRegister;
var
  Grupo: TGrupo;
  Grupos: TMapGrupos;
begin
  if (nbCrud.Tag= 0) then Exit;
  {=== Faz as validações ===}
  if not Validates then Exit;
  Grupo := TGrupo.Create;
  Grupos := TMapGrupos.Create(u_models.con, 'grupos');
  try
    Grupo.Nome       := edNome.Text.raw;
    Grupo.Ncm_padrao := edNcm_padrao.Text.raw_numbers;
    Grupo.Aliquota   := seAliquota.Value;
    Grupo.Tributacao := ArrayTrib[rgTributacao.ItemIndex];
    Grupo.Observacao := mmObs.Text.raw;
    Grupos.Nulls := True;
    if (pgDetails.Tag > 0) then
    begin
      Grupo.Id := pgDetails.Tag;
      Grupos.Modify(Grupo);
    end
    else
      Grupos.Add(Grupo);
    Grupos.Apply;
  finally
    Grupo.Free;
    Grupos.Free;
  end;
  GoBackToGrid;
  Flash(IfThen((pgDetails.Tag>0), 'Grupo modificado com sucesso', 'Grupo cadastrado com sucesso!'));
end;

procedure TfrmGrupos.CancelRegister;
begin
  if pgGrid.Showing then
    Close
  else
  begin
    GoBackToGrid;
    Flash('Operação cancelada.', kdNotify);
  end;
end;

procedure TfrmGrupos.SetSearch;
begin
  if pgGrid.Showing then edSearch.SetFocus;
end;

procedure TfrmGrupos.Flash(AMessage: String; AkdMsg: TKindMsg);
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

