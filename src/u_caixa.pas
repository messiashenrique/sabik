unit u_caixa;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, EditBtn, dSQLdbBroker, u_models, u_libs,
  u_busca_cliente, u_rules, u_recebimentos, pingrid, dUtils, strutils, Grids,
  Buttons, Menus;

type

  TReceitas = Array[0..7] of  Currency;

  { TfrmCaixa }
  TfrmCaixa = class(TForm)
    btnSearchCliente: TBitBtn;
    ckbParcelasPagas: TCheckBox;
    deDiaCaixa: TDateEdit;
    gridDiario: TPinGrid;
    gridResumo: TPinGrid;
    gridParcelas: TPinGrid;
    iml16: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    fCliente: TLabel;
    Label4: TLabel;
    lbReceitas: TLabel;
    lbRotuloDespesa: TLabel;
    lbRotuloReceita: TLabel;
    lbtotais: TLabel;
    lbUpdate: TLabel;
    lbRodape: TLabel;
    menuGrid: TPopupMenu;
    mnReceber: TMenuItem;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    pnResumoDiario: TPanel;
    pnPrevisao: TPanel;
    pnLancamentosTop: TPanel;
    pnLancamentos: TPanel;
    pnDiario: TPanel;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    tabDiario: TTabSheet;
    tabContasAReceber: TTabSheet;
    tabContasAPagar: TTabSheet;
    procedure btnSearchClienteClick(Sender: TObject);
    procedure ckbParcelasPagasChange(Sender: TObject);
    procedure deDiaCaixaChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure gridDiarioDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure gridParcelasDblClick(Sender: TObject);
    procedure gridParcelasDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure gridParcelasMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbUpdateClick(Sender: TObject);
    procedure mnReceberClick(Sender: TObject);
    procedure tabDiarioShow(Sender: TObject);
  private
    procedure CarregaCaixaDiario(ADate: TDateTime);
    procedure ResumeTotaisDiarios(ANumRegistros: Integer; AReceitas: TReceitas);
    procedure SearchPrestacoes(ACliente: Integer);
  public
    { public declarations }
  end;

var
  frmCaixa: TfrmCaixa;

implementation

{$R *.lfm}

{ TfrmCaixa }

procedure TfrmCaixa.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {=== Esc ===}
  if (Key=27) then Close;
end;

procedure TfrmCaixa.gridDiarioDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  VPagto, VProjecao: LongInt;
  VText: String;
begin
  {=== Identifica a forma de pagamento das receitas ===}
  if aRow = 0 then Exit;
  if (aCol=1) then
  begin
    VPagto := IfThen(gridDiario.TagCell[2, aRow] = 0, gridDiario.TagCell[1, aRow], 7);
    VText := gridDiario.Cells[1, aRow];
    gridDiario.Canvas.FillRect(aRect);
    gridDiario.Canvas.TextRect(aRect, aRect.Left + 1, aRect.Top, VText);
    iml16.Draw(gridDiario.Canvas, aRect.Right- 20, aRect.Top + 1, VPagto);
  end;
end;

procedure TfrmCaixa.gridParcelasDblClick(Sender: TObject);
begin
  if ((gridParcelas.RowCount > 1) and (gridParcelas.TagCell[7, gridParcelas.Row] <> 1)) then
     createFormWithTag(TfrmRecebimentos, frmRecebimentos, gridParcelas.TagCell[0, gridParcelas.Row]);
  SearchPrestacoes(btnSearchCliente.Tag);
  CarregaCaixaDiario(deDiaCaixa.Date);
end;

procedure TfrmCaixa.gridParcelasDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  S: String;
const
  ArrayColor: Array[0..2] of TColor=($00E6E6FF, $00F5FFEC, $00FFE1C4);
begin
  if aRow = 0 then Exit;
  if (aCol=7) and (gridParcelas.TagCell[7, aRow] > 0) then
  begin
    S := Trim(gridParcelas.Cells[7, aRow]);
    gridParcelas.Canvas.Brush.Color := ArrayColor[gridParcelas.TagCell[7, aRow]];
    gridParcelas.Canvas.FillRect(aRect);
    gridParcelas.Canvas.TextRect(aRect, aRect.Left, aRect.Top, S);
    //img16.Draw(gridLista.Canvas, aRect.Left + 3, aRect.Top + 1, VStatus);
  end;
end;

procedure TfrmCaixa.gridParcelasMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ((Button = mbRight) and (gridParcelas.RowCount > 1)) and
    (gridParcelas.TagCell[1, gridParcelas.Row] <> 2) then
    menuGrid.PopUp;
end;

procedure TfrmCaixa.lbUpdateClick(Sender: TObject);
begin
  CarregaCaixaDiario(deDiaCaixa.Date);
end;

procedure TfrmCaixa.mnReceberClick(Sender: TObject);
begin
  {=== Chama form de recebimento ===}
  gridParcelasDblClick(gridParcelas);
end;

procedure TfrmCaixa.tabDiarioShow(Sender: TObject);
begin
  CarregaCaixaDiario(deDiaCaixa.Date);
  gridResumo.RowHeights[1] := 18;
  gridDiario.SetFocus;
end;

procedure TfrmCaixa.FormCreate(Sender: TObject);
begin
  deDiaCaixa.Date := Date;
end;

procedure TfrmCaixa.deDiaCaixaChange(Sender: TObject);
begin
  CarregaCaixaDiario(deDiaCaixa.Date);
end;

procedure TfrmCaixa.btnSearchClienteClick(Sender: TObject);
var
  VCliente: Integer;
begin
  VCliente := createFormGetTag(TfrmBuscaCliente, frmBuscaCliente);
  btnSearchCliente.Tag := VCliente;
  if VCliente > 0 then
    SearchPrestacoes(VCliente);
end;

procedure TfrmCaixa.ckbParcelasPagasChange(Sender: TObject);
begin
  if btnSearchCliente.Tag > 0 then
    SearchPrestacoes(btnSearchCliente.Tag);
end;

procedure TfrmCaixa.CarregaCaixaDiario(ADate: TDateTime);
var
  Lancamento: TCaixa;
  qry: TdSQLdbQuery;
  i: Integer;
  VReceita: TReceitas;
begin
  qry := TdSQLdbQuery.Create(con);
  Lancamento := TCaixa.Create;
  for i := 0 to 7 do VReceita[i] := 0.0;

  try
    qry.SQL.Text := 'select * from caixa where data_lancamento = :data';
    qry.Params[0].AsDate := ADate;
    qry.Open;
    if not qry.IsEmpty then
    begin
      gridDiario.RowCount := qry.RowsAffected + 1;
      qry.First;
      for i := 1 to qry.RowsAffected do
      begin
        dUtils.dGetFields(Lancamento, qry.Fields);
        gridDiario.TagCell[0, i] := Lancamento.Id;
        gridDiario.Cells[0, i]   := i.to_s;
        gridDiario.Cells[1, i]   := Lancamento.Descricao;
        if (Trim(Lancamento.Tipo) = 'R') then
        begin
          gridDiario.Cells[2, i]   := Lancamento.Valor.to_m;
          gridDiario.TagCell[1, i] := Lancamento.Pagamento;
          gridDiario.TagCell[2, i] := Lancamento.Projecao;
          if (Lancamento.Projecao = 1) then
            VReceita[7] += Lancamento.Valor
          else
            VReceita[Lancamento.Pagamento] += Lancamento.Valor;

        end
        else
          gridDiario.Cells[3, i]   := Lancamento.Valor.to_m;
        qry.Next;
      end;
      ResumeTotaisDiarios(qry.RowsAffected, VReceita);
    end
    else
      ResumeTotaisDiarios(0, VReceita);
  finally
    Lancamento.Free;
  end;
end;

procedure TfrmCaixa.ResumeTotaisDiarios(ANumRegistros: Integer;
  AReceitas: TReceitas);
var
  q, i: Integer;
begin
  q := ANumRegistros;
  if (q = 0) then
  begin
    gridDiario.RowCount := 1;
    lbRodape.Caption := 'Nenhum lançamento para o dia.';
    lbReceitas.Caption := '';
    for i := 0 to 7 do gridResumo.Columns.Items[i].Visible := False;
    Exit;
  end;
  lbRodape.Caption    := IfThen(q>1, Format('%d lançamentos', [q]), 'Um lançamento');
  gridResumo.Columns.Items[0].Visible := AReceitas[0] > 0;
  gridResumo.Columns.Items[1].Visible := AReceitas[1] > 0;
  gridResumo.Columns.Items[2].Visible := AReceitas[2] > 0;
  gridResumo.Columns.Items[3].Visible := AReceitas[3] > 0;
  gridResumo.Columns.Items[4].Visible := AReceitas[4] > 0;
  gridResumo.Columns.Items[5].Visible := AReceitas[5] > 0;
  gridResumo.Columns.Items[6].Visible := AReceitas[6] > 0;
  gridResumo.Columns.Items[7].Visible := AReceitas[7] > 0;

  gridResumo.Cells[0,1] := AReceitas[0].to_m;
  gridResumo.Cells[1,1] := AReceitas[1].to_m;
  gridResumo.Cells[2,1] := AReceitas[2].to_m;
  gridResumo.Cells[3,1] := AReceitas[3].to_m;
  gridResumo.Cells[4,1] := AReceitas[4].to_m;
  gridResumo.Cells[5,1] := AReceitas[5].to_m;
  gridResumo.Cells[6,1] := AReceitas[6].to_m;
  gridResumo.Cells[7,1] := AReceitas[7].to_m;

  lbReceitas.Caption  := 'R$ '+ (AReceitas[0] + AReceitas[7]).to_m;
end;

procedure TfrmCaixa.SearchPrestacoes(ACliente: Integer);
var
  Prestacoes: TPrestacoes;
  query: TdSQLdbQuery;
  i: Integer;
  VCliente: IGetCliente;
begin
  Prestacoes := TPrestacoes.Create;
  query := TdSQLdbQuery.Create(con);
  if ckbParcelasPagas.Checked then
    query.SQL.Text := 'select * from prestacoes where cliente = :cliente order by data_vencimento'
  else
    query.SQL.Text := 'select * from prestacoes where (status=''A'') and (cliente = :cliente) order by data_vencimento';
  query.Params[0].AsInteger := ACliente;
  try
    query.Open;
    if not query.IsEmpty then
    begin
      VCliente := TGetCliente.new(ACliente);
      fCliente.Caption := VCliente.nome;
      gridParcelas.RowCount := query.RowsAffected + 1;
      query.First;
      for i := 1 to query.RowsAffected do
      begin
        dUtils.dGetFields(Prestacoes, query.Fields);
        gridParcelas.TagCell[0, i] := Prestacoes.Id;
        gridParcelas.Cells[0, i]   := i.to_s;
        gridParcelas.Cells[1, i]   := Prestacoes.Data_compra.to_s;
        gridParcelas.Cells[2, i]   := Prestacoes.Data_vencimento.to_s;
        gridParcelas.Cells[3, i]   := Prestacoes.Parcela.to_s + '/' + Prestacoes.Parcelas.to_s;
        gridParcelas.Cells[4, i]   := Prestacoes.Valor_parcela.to_m;
        gridParcelas.Cells[5, i]   := Prestacoes.Valor_pagamento.to_m;
        if (Trim(Prestacoes.Status.up) = 'P') then
        begin
          gridParcelas.TagCell[7, i] := 1;
          gridParcelas.Cells[7, i] := 'PAGA';
        end
        else
        begin
          if (Prestacoes.Valor_pagamento > 0) then
          begin
            gridParcelas.TagCell[7, i] := 2;
            gridParcelas.Cells[7, i] := 'Restando: ' + (Prestacoes.Valor_parcela - Prestacoes.Valor_pagamento).to_m;
          end
          else
          begin
            gridParcelas.TagCell[7, i] := 0;
            gridParcelas.Cells[7, i] := '';
          end;
        end;
        query.Next;
      end;
    end
    else
    begin
      gridParcelas.RowCount := 0;
      fCliente.Caption := '';
    end;
  finally
    query.Free;
    Prestacoes.Free;
  end;
end;

end.

