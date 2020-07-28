unit u_dfs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, pingrid, dSQLdbBroker, u_models, u_libs, u_dm,
  u_rules, dUtils, strutils, dateutils, Grids, ComCtrls, Menus, EditBtn,
  ACBrNFe, pcnConversao, ACBrDANFCeFortesFr, LCLType;

type

  { TfrmDFs }

  TfrmDFs = class(TForm)
    danfe: TACBrNFeDANFCeFortes;
    deIni: TDateEdit;
    deFim: TDateEdit;
    Label1: TLabel;
    Label2: TLabel;
    lbRefresh: TLabel;
    mnCancelar: TMenuItem;
    mnInutilizar: TMenuItem;
    mnReimprimir: TMenuItem;
    nfe: TACBrNFe;
    chgFiltros: TRadioGroup;
    grid: TPinGrid;
    Image2: TImage;
    img16: TImageList;
    lbTitulo: TLabel;
    menuGrid: TPopupMenu;
    mnExibirDANFCe: TMenuItem;
    pnPeriod: TPanel;
    pbSearch: TPanel;
    rgPeriod: TRadioGroup;
    sb: TStatusBar;
    procedure chgFiltrosSelectionChanged(Sender: TObject);
    procedure deFimChange(Sender: TObject);
    procedure deIniChange(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure gridDrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect;
      aState: TGridDrawState);
    procedure gridKeyPress(Sender: TObject; var Key: char);
    procedure gridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbRefreshClick(Sender: TObject);
    procedure mnCancelarClick(Sender: TObject);
    procedure mnExibirDANFCeClick(Sender: TObject);
    procedure mnInutilizarClick(Sender: TObject);
    procedure mnReimprimirClick(Sender: TObject);
    procedure rgPeriodSelectionChanged(Sender: TObject);
    procedure sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
  private
    procedure search(AScript: String; ADateIni, ADateFim: TDateTime);
    procedure searchDefault;
    procedure CancelarNFCe;
    procedure Inutilizar(ANumNFCe: Integer);
    //procedure AtualizaEstatistica;
  public
    procedure CallSearchDefault;
  end;

var
  frmDFs: TfrmDFs;

implementation

{$R *.lfm}

{ TfrmDFs }

procedure TfrmDFs.edSearchChange(Sender: TObject);
var
  p, Vwhere: String;
  VAno: Integer;
begin
  //p := '''%'+edSearch.Text.raw+'%''';
  //
  //VAno := YearOf(Date);
  //case chgFiltros.ItemIndex of
  //  0: Vwhere := ' and (balanco<' + VAno.to_s+')';
  //  1: Vwhere := ' and (balanco>=' + VAno.to_s+')';
  //  2: Vwhere := '';
  //end;
  //
  //if (Length(edSearch.Text) > 0) then
  //  search('select id, descricao, preco_venda, estoque, ean13, balanco from produtos where'+
  //         '(id>0) and ((descricao like '+p+') or (id like '+p+') or (ean13 '+
  //         'like '+p+') or (referencia like '+p+')) ' + Vwhere)
  //else
  //  searchDefault;
end;

procedure TfrmDFs.chgFiltrosSelectionChanged(Sender: TObject);
begin
  searchDefault;
end;

procedure TfrmDFs.deFimChange(Sender: TObject);
begin
  searchDefault;
end;

procedure TfrmDFs.deIniChange(Sender: TObject);
begin
  searchDefault;
end;

procedure TfrmDFs.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key = 40) or (Key = 13)) and (grid.RowCount > 1) then grid.SetFocus;
end;

procedure TfrmDFs.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {=== Esc ===}
  if (Key=27) then
  begin
    grid.RowCount := 1;
    Close;
  end;
end;

procedure TfrmDFs.FormShow(Sender: TObject);
begin
  deIni.Date := Date - 7;
  deFim.Date := Date;
  searchDefault;
end;

procedure TfrmDFs.gridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  S: String;
  VStatus: Integer;
const
  ArrayColor: Array[0..4] of TColor=($00DFF8FF, $00F5FFEC, $00D2D2FF, $0095CAFF, $00C9C9C9);
begin
  if (aRow = 0) then Exit;
  if (aCol = 8) then
  begin
    case grid.TagCell[8, aRow] of
        0: VStatus := 0;
      100: VStatus := 1;
      101: VStatus := 2;
      102: VStatus := 3;
      else VStatus := 4;
    end;
    S := grid.Cells[8, aRow];
    if VStatus > -1 then
    begin
      grid.Canvas.Brush.Color := ArrayColor[VStatus];
      grid.Canvas.FillRect(aRect);
      grid.Canvas.TextRect(aRect, aRect.Left + 25, aRect.Top, S);
      //img16.Draw(grid.Canvas, aRect.Left + 3, aRect.Top + 1, VStatus);
    end;
  end;
end;

procedure TfrmDFs.gridKeyPress(Sender: TObject; var Key: char);
//var
//  aCol, aRow: Integer;
begin
  //aCol := grid.Col;
  //aRow := grid.Row;
  //case aCol of
  //  6: if (Key in [#67, #99]) then Confere(aRow);
  //  2, 5: Key := OnlyKeyNumbers(Key);
  //  3, 4: Key := OnlyKeyMoney(Key);
  //end;
end;

procedure TfrmDFs.gridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  C, R: Longint;
begin
  if ((Button = mbRight) and (grid.RowCount > 1)) then
  begin
    grid.MouseToCell(X, Y, C, R);
    grid.Col := C;
    grid.Row := R;
    case (grid.TagCell[7, grid.Row]) of
      1: if (grid.TagCell[8, grid.Row] = 100) then
      begin
        mnExibirDANFCe.Visible := True;
        mnReimprimir.Visible   := True;
        mnCancelar.Visible     := False;
        mnInutilizar.Visible   := False;
      end
      else
      begin
        mnExibirDANFCe.Visible := False;
        mnReimprimir.Visible   := False;
        mnCancelar.Visible     := False;
        mnInutilizar.Visible   := True;
      end;
      9: begin
        mnExibirDANFCe.Visible := True;
        mnReimprimir.Visible   := True;
        mnCancelar.Visible     := False;
        mnInutilizar.Visible   := False;
      end;
    end;
    if (grid.TagCell[8, grid.Row] in [101, 102]) then
    begin
      mnCancelar.Visible   := False;
      mnInutilizar.Visible := False;
    end;
    menuGrid.PopUp;
  end;
end;

procedure TfrmDFs.lbRefreshClick(Sender: TObject);
begin
  searchDefault;
end;

procedure TfrmDFs.mnCancelarClick(Sender: TObject);
begin
  CancelarNFCe;
end;

procedure TfrmDFs.mnExibirDANFCeClick(Sender: TObject);
begin
  {=== Visualiza o DANFCE ===}
  nfe.NotasFiscais.Clear;
  nfe.NotasFiscais.LoadFromFile(grid.Cells[9, grid.Row]);
  nfe.DANFE.MostrarPreview := True;
  nfe.DANFE.ImprimirDANFE();
end;

procedure TfrmDFs.mnInutilizarClick(Sender: TObject);
begin
  {=== Inutilizar ===}
  Inutilizar(grid.TagCell[0, grid.Row]);
end;

procedure TfrmDFs.mnReimprimirClick(Sender: TObject);
begin
  {=== Reimprimir DANFCe ===}
  dm.nfe.NotasFiscais.Clear;
  dm.nfe.NotasFiscais.LoadFromFile(grid.Cells[9, grid.Row]);
  try
    dm.nfe.DANFE.ImprimirDANFE();
  finally
    dm.nfe.NotasFiscais.Clear;
  end;
end;

procedure TfrmDFs.rgPeriodSelectionChanged(Sender: TObject);
begin
  pnPeriod.Visible := rgPeriod.ItemIndex = 1;
  searchDefault;
end;

procedure TfrmDFs.sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  //case Panel.Index of
  //  0: img16.Draw(sb.Canvas, Rect.Left, Rect.Top, 1);
  //  2: img16.Draw(sb.Canvas, Rect.Left, Rect.Top, 2);
  //  4: img16.Draw(sb.Canvas, Rect.Left, Rect.Top, 3);
  //end;
end;

procedure TfrmDFs.search(AScript: String; ADateIni, ADateFim: TDateTime);
const
  ArrayTpEmis: Array[0..9] of String=('-','Normal', '-', '-', '-', '-',  '-', '-', '-', 'Contigência Offline');
var
  qry: TdSQLdbQuery;
  i: Integer;
  DF: TDocumentoFiscal;
begin
  qry := TdSQLdbQuery.Create(con);
  DF := TDocumentoFiscal.Create;
  qry.SQL.Text := AScript;
  qry.Params.Items[0].AsDateTime := ADateIni;
  qry.Params.Items[1].AsDateTime := ADateFim;
  try
    qry.Open;
    if not qry.IsEmpty then
    begin
      grid.RowCount := qry.RowsAffected + 1;
      qry.First;
      for i := 1 to qry.RowsAffected do
      begin
        dUtils.dGetFields(DF, qry.Fields);
        grid.TagCell[0, i] := DF.Id;
        grid.Cells[0, i]   := DF.Id.to_s;
        grid.Cells[1, i]   := DF.Serie.to_s;
        grid.Cells[2, i]   := DF.chNFe;
        grid.Cells[3, i]   := DF.Pedido.to_s;
        grid.Cells[4, i]   := FormatDateTime('dd/mm/yyyy - hh:nn', DF.dhEmis);
        if DF.dhRecbto < DF.dhEmis then
          grid.Cells[5, i]   := ''
        else
          grid.Cells[5, i]   := FormatDateTime('dd/mm/yyyy - hh:nn', DF.dhRecbto);
        grid.Cells[6, i]   := DF.Valor.to_m;
        grid.Cells[7, i]   := ArrayTpEmis[DF.tpEmis];
        grid.TagCell[7, i] := DF.tpEmis;
        grid.TagCell[8, i] := DF.cStat;
        case DF.cStat of
            0: grid.Cells[8, i]   := 'Aguardando envio';
          100: grid.Cells[8, i]   := 'Autorizada';
          101: grid.Cells[8, i]   := 'Cancelada';
          102: grid.Cells[8, i]   := 'Inutilizada';
          else grid.Cells[8, i]   := 'Desconhecido';
        end;
        grid.Cells[9, i]   := DF.Path_xml;
        qry.Next;
      end;
    end
    else
      grid.RowCount := 1;
  finally
    DF.Free;
    qry.Free;
  end;
  //AtualizaEstatistica;
end;

procedure TfrmDFs.searchDefault;
var
  Vwhere: String;
  VIni, VFim: TDateTime;
begin
  VIni := GetFirstDayMonth(Date);
  VFim := GetLastDayMonth(Date);
  case chgFiltros.ItemIndex of
    0: Vwhere := ' and (dhemis between :ini and :fim)';
    1: Vwhere := ' and (cstat in (100,150)) and (dhemis between :ini and :fim)';
    2: Vwhere := ' and (cstat = 0) and (dhemis between :ini and :fim)';
    3: Vwhere := ' and (cstat = 135) and (dhemis between :ini and :fim)';
  end;
  case rgPeriod.ItemIndex of
    0: Search('select * from documento_fiscal ' +
              'where (id>0) ' + Vwhere + ' order by id desc', VIni, VFim);
    1: Search('select * from documento_fiscal ' +
              'where (id>0) ' + Vwhere + ' order by id desc', deIni.Date, deFim.Date);
  end;

end;

procedure TfrmDFs.CancelarNFCe;
var
  vAux: String;
  VPrazo: TDateTime;
  dias: Int64;
  DF: TDocumentoFiscal;
  DFs: TMapDocumentoFiscal;
label
  justificativa;
begin
  //{=== Verifica se a NFCe está autorizada ===}
  //if grid.TagCell[8, grid.Row] <> 100 then
  //begin
  //  ShowMessage('Apenas NFCe''s "Autorizadas" podem ser canceladas!');
  //  Exit;
  //end;
  //{=== Carrega a NFCe ===}
  //dm.nfe.NotasFiscais.Clear;
  //dm.nfe.NotasFiscais.LoadFromFile(grid.Cells[9, grid.Row]);
  //{=== Verifica se a NFCe foi emtidida em até 24 horas ===}
  //VPrazo := Now - dm.nfe.NotasFiscais.Items[0].NFe.procNFe.dhRecbto;
  //dias := trunc(VPrazo);
  //if dias > 0 then
  //begin
  //  ShowMessage('Não é possível cancelar uma NFCe emitida há mais de 24 horas!');
  //  Exit;
  //end;
  //
  //{=== Pede para o susário digitar uma justificativa ===}
  //justificativa: {## Label ##}
  //if not(InputQuery('Cancelamento', 'Digite uma justificativa ', vAux)) then
  //  exit;
  //
  //{=== Verifica se a NFCe foi emtidida em até 24 horas ===}
  //while Length(vAux) < 15 do
  //begin
  //  ShowMessage('A justificativa deve ter, no mínimo 15 caracteres!');
  //  goto justificativa;
  //end;
  //
  //
  //dm.nfe.EventoNFe.Evento.Clear;
  //dm.nfe.EventoNFe.idLote := 1;
  //
  //with dm.nfe.EventoNFe.Evento.Add do
  //begin
  //  infEvento.dhEvento := now;
  //  infEvento.tpEvento := teCancelamento;
  //  infEvento.detEvento.xJust := vAux;
  //end;
  //
  //dm.nfe.EnviarEvento(1);
  //if dm.nfe.WebServices.EnvEvento.cStat = 128 then
  //ShowMessage('Evento transmitido à Sefaz');
  //if dm.nfe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.cStat = 135 then
  begin
    {=== Gravar no Banco de dados ===}
    DF := TDocumentoFiscal.Create;
    DFs := TMapDocumentoFiscal.Create(con, 'documento_fiscal');
    try
      DF.Id := grid.TagCell[0, grid.Row];
      DF.cStat     := 135;
      DF.xMotivo   := 'blá blá blá'; //dm.nfe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.xMotivo;
      DFs.Nulls    := True;
      DFs.Table.IgnoredFields.Add('pedido');
      DFs.Modify(DF);
      DFs.Apply;
    finally
      searchDefault;
      DF.Free;
      DFs.Free;
    end;
  end
  //else
  //  ShowMessage('Não foi possível cancelar a NFCe'+ #13 + 'Motivo: '+
  //               dm.nfe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.xMotivo);
end;

procedure TfrmDFs.Inutilizar(ANumNFCe: Integer);
var
 Justificativa : String;
 Empresa: TEmpresa;
 Empresas: TMapEmpresas;
 DF: TDocumentoFiscal;
 DFs: TMapDocumentoFiscal;
begin
  if not(InputQuery('WebServices Inutilização ', 'Justificativa', Justificativa)) then
     exit;
  Empresa := TEmpresa.Create;
  Empresas := TMapEmpresas.Create(con, 'empresa');
  DF := TDocumentoFiscal.Create;
  DFs := TMapDocumentoFiscal.Create(con, 'documento_fiscal');
  try
    Empresa.Id := 1;
    Empresas.Get(Empresa);
    try
      dm.nfe.WebServices.Inutiliza(Empresa.Cnpj, Justificativa, 2017, 65, 1, ANumNFCe, ANumNFCe);
      case dm.nfe.WebServices.Inutilizacao.cStat of
        102: begin
          DF.Id := ANumNFCe;
          if DFs.Get(DF) then
          begin
            DFs.Remove(DF);
            dfs.Apply;
          end;
          DF.Id        := ANumNFCe;
          DF.chNFe     := dm.nfe.WebServices.Inutilizacao.ID;
          DF.nProt     := dm.nfe.WebServices.Inutilizacao.Protocolo;
          DF.Serie     := dm.nfe.WebServices.Inutilizacao.Serie;
          DF.chNFe     := dm.nfe.WebServices.Inutilizacao.ID;
          DF.dhEmis    := dm.nfe.WebServices.Inutilizacao.dhRecbto;
          DF.dhRecbto  := dm.nfe.WebServices.Inutilizacao.dhRecbto;
          DF.cStat     := dm.nfe.WebServices.Inutilizacao.cStat;
          DF.xMotivo   := dm.nfe.WebServices.Inutilizacao.xMotivo;
          DFs.Nulls    := True;
          DFs.Table.IgnoredFields.Add('pedido');
          DFs.Add(DF, False);
          DFs.Apply;
        end;
        else
          ShowMessage('Erro ao tentar a inutilização');
      end;
    except
      on E: Exception do ShowMessage(E.Message);
    end;
  finally
    searchDefault;
    DF.Free;
    DFs.Free;
    Empresa.Free;
    Empresas.Free;
  end;
end;

procedure TfrmDFs.CallSearchDefault;
begin
  searchDefault;
end;

end.

