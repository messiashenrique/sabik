unit u_busca_cliente;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, pingrid, dSQLdbBroker, u_models, u_libs, dUtils, strutils;

type

  { TfrmBuscaCliente }

  TfrmBuscaCliente = class(TForm)
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
  frmBuscaCliente: TfrmBuscaCliente;

implementation

{$R *.lfm}

{ TfrmBuscaCliente }

procedure TfrmBuscaCliente.edSearchChange(Sender: TObject);
var
  p: String;
begin
  p := '''%'+edSearch.Text.raw+'%''';
  if (Length(edSearch.Text) > 0) then
    search('select id, nome, cpf_cnpj, celular_1 from clientes where (id>0) and '+
           '((nome like '+p+') or (cpf_cnpj like '+p+') or (celular_1 like '+p+'))')
  else
    searchDefault;
end;

procedure TfrmBuscaCliente.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key = 40) or (Key = 13)) and (grid.RowCount > 1) then grid.SetFocus;
end;

procedure TfrmBuscaCliente.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if (grid.RowCount > 1) then
    Tag := grid.TagCell[0, grid.Row];
end;

procedure TfrmBuscaCliente.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {=== Esc ===}
  if (Key=27) then
  begin
    grid.RowCount := 1;
    Close;
  end;
end;

procedure TfrmBuscaCliente.FormShow(Sender: TObject);
begin
  searchDefault;
  edSearch.SetFocus;
end;

procedure TfrmBuscaCliente.gridDblClick(Sender: TObject);
begin
  if grid.RowCount > 1 then Close;
end;

procedure TfrmBuscaCliente.gridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key in [13, 27])  then Close; {=== Esc ou Enter ===}
  if (key = 114) then edSearch.SetFocus; {=== F3 ===}
end;

procedure TfrmBuscaCliente.search(AScript: String);
var
  qry: TdSQLdbQuery;
  Cliente: TCliente;
  i: Integer;
  q: Int64;
begin
  qry := TdSQLdbQuery.Create(con);
  Cliente := TCliente.Create;
  qry.SQL.Text := AScript;
  try
    qry.Open;
    if not qry.IsEmpty then
    begin
      grid.RowCount := qry.RowsAffected + 1;
      qry.First;
      for i := 1 to qry.RowsAffected do
      begin
        dUtils.dGetFields(Cliente, qry.Fields);
        grid.TagCell[0, i] := Cliente.Id;
        grid.Cells[0, i] := Cliente.Id.to_s;
        grid.Cells[1, i] := Cliente.Nome;
        grid.Cells[2, i] := Cliente.Cpf_cnpj.maskCpfCnpj;
        grid.Cells[3, i] := Cliente.Celular_1.maskPhone;
        qry.Next;
      end;
      q := qry.RowsAffected;
      lbRodape.Caption := IfThen(q>1, Format('%d clientes encontrados', [q]), 'Um cliente encontrado');
    end
    else
    begin
      grid.RowCount := 1;
      lbRodape.Caption := 'Nenhum Cliente encontrado';
    end;
  finally
    Cliente.Free;
    qry.Free;
  end;
end;

procedure TfrmBuscaCliente.searchDefault;
begin
  Search('select id, nome, cpf_cnpj, celular_1 from clientes where id>0 order by id desc');
end;

end.

