unit u_busca_produto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, pingrid, dSQLdbBroker, u_models, u_libs, dUtils, strutils;

type

  { TfrmBuscaProduto }

  TfrmBuscaProduto = class(TForm)
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
  frmBuscaProduto: TfrmBuscaProduto;

implementation

{$R *.lfm}

{ TfrmBuscaProduto }

procedure TfrmBuscaProduto.edSearchChange(Sender: TObject);
var
  p: String;
begin
  p := '''%'+edSearch.Text.raw+'%''';
  if (Length(edSearch.Text) > 0) then
    search('select id, descricao, preco_venda, estoque from produtos where'+
           '(id>0) and ((descricao like '+p+') or (id like '+p+') or (ean13 '+
           'like '+p+') or (referencia like '+p+'))')
  else
    searchDefault;
end;

procedure TfrmBuscaProduto.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key = 40) or (Key = 13)) and (grid.RowCount > 1) then grid.SetFocus;
end;

procedure TfrmBuscaProduto.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if (grid.RowCount > 1) then
    Tag := grid.TagCell[0, grid.Row];
end;

procedure TfrmBuscaProduto.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {=== Esc ===}
  if (Key=27) then
  begin
    grid.RowCount := 1;
    Close;
  end;
end;

procedure TfrmBuscaProduto.FormShow(Sender: TObject);
begin
  searchDefault;
end;

procedure TfrmBuscaProduto.gridDblClick(Sender: TObject);
begin
  if grid.RowCount > 1 then Close;
end;

procedure TfrmBuscaProduto.gridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key in [13, 27])  then Close; {=== Esc ou Enter ===}
  if (key = 114) then edSearch.SetFocus; {=== F3 ===}
end;

procedure TfrmBuscaProduto.search(AScript: String);
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
      grid.RowCount := qry.RowsAffected + 1;
      qry.First;
      for i := 1 to qry.RowsAffected do
      begin
        dUtils.dGetFields(Produto, qry.Fields);
        grid.TagCell[0, i] := Produto.Id;
        grid.Cells[0, i] := Produto.Id.to_s;
        grid.Cells[1, i] := Produto.Descricao;
        grid.Cells[2, i] := Produto.Estoque.to_s;
        grid.Cells[3, i] := Produto.Preco_venda.to_m;
        qry.Next;
      end;
      q := qry.RowsAffected;
      lbRodape.Caption := IfThen(q>1, Format('%d produtos encontrados', [q]), 'Um produto encontrado');
    end
    else
    begin
      grid.RowCount := 1;
      lbRodape.Caption := 'Nenhum produto encontrado';
    end;
  finally
    Produto.Free;
    qry.Free;
  end;
end;

procedure TfrmBuscaProduto.searchDefault;
begin
  Search('select id, descricao, estoque, preco_venda from produtos where id>0 order by id desc');
end;

end.

