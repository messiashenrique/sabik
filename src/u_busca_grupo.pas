unit u_busca_grupo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, pingrid, dSQLdbBroker, u_models, u_libs, dUtils, strutils;

type

  { TfrmBuscaGrupo }

  TfrmBuscaGrupo = class(TForm)
    btnOk: TBitBtn;
    edSearch: TEdit;
    grid: TPinGrid;
    Image1: TImage;
    lbRodape: TLabel;
    lbTitulo: TLabel;
    pnControl: TPanel;
    pbSearch: TPanel;
    procedure edSearchChange(Sender: TObject);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure gridDblClick(Sender: TObject);
    procedure gridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure search(AScript: String);
    procedure searchDefault;
  public
    { public declarations }
  end;

var
  frmBuscaGrupo: TfrmBuscaGrupo;

implementation

{$R *.lfm}

{ TfrmBuscaGrupo }

procedure TfrmBuscaGrupo.edSearchChange(Sender: TObject);
var
  p: String;
begin
  p := '''%'+edSearch.Text.raw+'%''';
  if (Length(edSearch.Text) > 0) then
    search('select id, nome, ncm_padrao from grupos where'+
           '((nome like '+p+') or (id like '+p+'))')
  else
    searchDefault;
end;

procedure TfrmBuscaGrupo.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key = 40) or (Key = 13)) and (grid.RowCount > 1) then grid.SetFocus;
end;

procedure TfrmBuscaGrupo.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if (grid.RowCount > 1) then
    Tag := grid.TagCell[0, grid.Row];
end;

procedure TfrmBuscaGrupo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {=== Esc ===}
  if (Key=27) then
  begin
    grid.RowCount := 1;
    Close;
  end;
end;

procedure TfrmBuscaGrupo.FormShow(Sender: TObject);
begin
  searchDefault;
end;

procedure TfrmBuscaGrupo.gridDblClick(Sender: TObject);
begin
  if grid.RowCount > 1 then Close;
end;

procedure TfrmBuscaGrupo.gridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key in [13, 27])  then Close; {=== Esc ou Enter ===}
  if (key = 114) then edSearch.SetFocus; {=== F3 ===}
end;

procedure TfrmBuscaGrupo.search(AScript: String);
var
  qry: TdSQLdbQuery;
  Grupo: TGrupo;
  i: Integer;
  q: Int64;
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
        qry.Next;
      end;
      q := qry.RowsAffected;
      lbRodape.Caption := IfThen(q>1, Format('%d grupos encontrados', [q]), 'Um grupo encontrado');
    end
    else
    begin
      grid.RowCount := 1;
      lbRodape.Caption := 'Nenhum grupo encontrado';
    end;
  finally
    Grupo.Free;
    qry.Free;
  end;
end;

procedure TfrmBuscaGrupo.searchDefault;
begin
  Search('select id, nome, ncm_padrao from grupos where id > 0');
end;

end.

