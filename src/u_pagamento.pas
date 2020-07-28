unit u_pagamento;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, EditBtn, Spin, u_libs, u_models,
  u_busca_cliente, u_rules, PinDatas, strutils;

type

  TPlots = array of double;

  { TfrmPagamento }

  TfrmPagamento = class(TForm)
    btnOk: TBitBtn;
    cbFormaPgto: TComboBox;
    dePrimeiroVencimento: TDateEdit;
    fSubtotal: TLabel;
    fDesconto: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    lbPrimeiroVencimento: TLabel;
    lbSubTotal: TLabel;
    lbDesconto: TLabel;
    fTotal: TLabel;
    lbNumDeParcelas: TLabel;
    lbCifrao: TLabel;
    pnInfo: TPanel;
    lbParcelas: TLabel;
    lbTitulo: TLabel;
    lbRodape: TLabel;
    pnAprazo: TPanel;
    seQtdeParcelas: TSpinEdit;
    procedure btnOkClick(Sender: TObject);
    procedure cbFormaPgtoChange(Sender: TObject);
    procedure dePrimeiroVencimentoChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure seQtdeParcelasChange(Sender: TObject);
  private
    function Parcelar(Valor: Extended; Parcelas: integer): TPlots;
    procedure calcularParcelas(AQtdeParcelas: Integer);
    procedure EfetuaPgto(AFormaPgto, APedido, AParcelas: Integer);
    procedure FaturaPedido(APedido, AFormaPgto, AParcelas: Integer);
    procedure LancaNoCaixa(APedido: IGetPedido);
    procedure LancaVendaNoCaixa(APedido: IGetPedido);
    procedure LancaPrevisao(APedido: IGetPedido; AParcela: Integer);
    procedure LancaParcelas(APedido: IGetPedido);
    function FormatDateFontMono(ADate: TDateTime): String;
    function GetClienteIfNeeded(APedido: Integer): Integer;
  public
    { public declarations }
  end;

var
  frmPagamento: TfrmPagamento;

implementation

{$R *.lfm}

{ TfrmPagamento }

procedure TfrmPagamento.seQtdeParcelasChange(Sender: TObject);
var
  VAltura: Integer;
begin
  if (cbFormaPgto.ItemIndex = 6) then Exit;
  calcularParcelas(seQtdeParcelas.Value);
  if (cbFormaPgto.ItemIndex = 1) then
  begin
    VAltura := (seQtdeParcelas.Value -1 ) * 18;
    pnAprazo.Height := 80 + VAltura;
    Height := 227 + VAltura;
  end;
end;

procedure TfrmPagamento.cbFormaPgtoChange(Sender: TObject);
begin
  if (cbFormaPgto.ItemIndex in [1,3]) then
  begin
    pnAprazo.Height := 80;
    Height := 227;
    calcularParcelas(1);
    dePrimeiroVencimento.Visible := cbFormaPgto.ItemIndex = 1;
    lbPrimeiroVencimento.Caption := 'Primeiro vencimento';
    lbPrimeiroVencimento.Visible := cbFormaPgto.ItemIndex = 1;
    seQtdeParcelas.Visible       := True;
    lbParcelas.Visible           := True;
  end
  else if (cbFormaPgto.ItemIndex = 6) then
  begin
    pnAprazo.Height := 50;
    Height := 197;
    dePrimeiroVencimento.Visible := True;
    lbPrimeiroVencimento.Caption := 'Pré-datado para';
    lbPrimeiroVencimento.Visible := True;
    lbNumDeParcelas.Visible      := False;
    lbParcelas.Visible           := False;
    seQtdeParcelas.Visible       := False;
  end
  else
  begin
    Height := 147;
    pnAprazo.Height := 0;
  end;
end;

procedure TfrmPagamento.dePrimeiroVencimentoChange(Sender: TObject);
begin
  {=== Recalcula as parcelas ===}

end;

procedure TfrmPagamento.btnOkClick(Sender: TObject);
begin
  case cbFormaPgto.ItemIndex of
    0: EfetuaPgto(cbFormaPgto.ItemIndex, Tag, 0);
    2,4,5,6: EfetuaPgto(cbFormaPgto.ItemIndex, Tag, 1);
    1,3: EfetuaPgto(cbFormaPgto.ItemIndex, Tag, seQtdeParcelas.Value);
  end;
  Close;
end;

procedure TfrmPagamento.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 27) then Close;
end;

procedure TfrmPagamento.FormShow(Sender: TObject);
var
  Pedido: TPedido;
  Pedidos: TMapPedidos;
  VTotal: Currency;
begin
  Pedido  := TPedido.Create;
  Pedidos := TMapPedidos.Create(con, 'pedidos');
  VTotal := 0;
  try
    Pedido.Id := Tag;
    Pedidos.Get(Pedido);
    if Pedido.Desconto > 0 then
    begin
      lbSubTotal.Visible := True;
      lbDesconto.Visible := True;
      fSubtotal.Caption  := Pedido.Subtotal.to_m;
      fDesconto.Caption  := Pedido.Desconto.to_m;
    end
    else
    begin
      lbSubTotal.Visible := False;
      lbDesconto.Visible := False;
      fSubtotal.Caption  := '';
      fDesconto.Caption  := '';
    end;
    dePrimeiroVencimento.Date := DiaUtilApartirDe(MesComercialAdiante(Pedido.Data));
    VTotal := (Pedido.Subtotal - Pedido.Desconto);
    fTotal.Caption := VTotal.to_m;
  finally
    Pedido.Free;
    Pedidos.Free;
  end;
end;

function TfrmPagamento.Parcelar(Valor: Extended; Parcelas: integer): TPlots;
var
  vParcela, vDiferenca, vSoma, i: Integer;
begin
  SetLength(Result, Parcelas);
  vSoma := 0;
  vParcela := trunc(((Valor *100) / Parcelas));
  vSoma := vParcela * Parcelas;
  for i := 0 to Parcelas - 1 do
    Result[i] := vParcela / 100;
  vDiferenca := trunc(Valor * 100) - vSoma;
  if vDiferenca > 0 then
    for i := 0 to vDiferenca - 1  do
      Result[i] := Result[i] + 0.01;
end;

procedure TfrmPagamento.calcularParcelas(AQtdeParcelas: Integer);
var
  SL: TStringList;
  Data: TDateTime;
  numParc, i: Integer;
  valorParc: Currency;
begin
  if (cbFormaPgto.ItemIndex = 1) then
  begin
    SL := TStringList.Create;
    SL.Add('PARCELA   VENCIMENTO    VALOR  ');
    Data := dePrimeiroVencimento.Date;
    numParc := seQtdeParcelas.Value;
    for i := 0 to numParc - 1 do
    begin
      with SL do
      begin
        Add(IfThen(i>8, '  ', '   ') + IntToStr(i + 1) + 'ª     ' + FormatDateFontMono(DiaUtilApartirDe(Data)) +
            '   R$ ' + FormatFloat('### ###,##0.00 ',
        Parcelar(fTotal.Caption.to_f, numParc)[i]));
        Data := MesComercialAdiante(Data);
      end;
    end;
    lbParcelas.Caption := SL.Text;
    SL.Free;
  end
  else
  begin
    SL := TStringList.Create;
    numParc := seQtdeParcelas.Value;
    valorParc := (fTotal.Caption.to_f / numParc);
    if (numParc = 1) then
      SL.Add('UMA PARCELA NO VALOR DE R$ ' + valorParc.to_m)
    else
      SL.Add(numParc.to_s +' PARCELAS NO VALOR DE R$ ' + valorParc.to_m);
    lbParcelas.Caption := SL.Text;
    SL.Free;
  end;
end;

procedure TfrmPagamento.EfetuaPgto(AFormaPgto, APedido, AParcelas: Integer);
begin
  FaturaPedido(APedido, AFormaPgto, AParcelas);
  LancaNoCaixa(TGetPedido.new(APedido));
end;

procedure TfrmPagamento.FaturaPedido(APedido, AFormaPgto, AParcelas: Integer);
var
  Pedido: TPedido;
  Pedidos: TMapPedidos;
  VCliente: Integer;
begin
  VCliente := 0;
  if (AFormaPgto = 1) and (TGetPedido.new(APedido).cliente = 0) then
  begin
    VCliente := GetClienteIfNeeded(APedido);
    if (VCliente = 0) then Exit;
  end;
  Pedido  := TPedido.Create;
  Pedidos := TMapPedidos.Create(con, 'pedidos');
  try
    Pedido.Id := APedido;
    Pedidos.Get(Pedido);
    Pedido.Pagamento := AFormaPgto;
    Pedido.Parcelas := AParcelas;
    Pedido.Status := 'F';
    if VCliente > 0 then Pedido.Cliente := VCliente;
    Pedidos.Modify(Pedido);
    Pedidos.Apply;
  finally
    Pedido.Free;
    Pedidos.Free;
  end;
end;

procedure TfrmPagamento.LancaNoCaixa(APedido: IGetPedido);
var
  i: Integer;
begin
  LancaVendaNoCaixa(APedido);
  case APedido.pagamento of
    1: LancaParcelas(APedido);
    2..5: for i := 1 to APedido.parcelas do LancaPrevisao(APedido, i);
    6: LancaPrevisao(APedido, 1);
    //5: LancaPrevisao(APedido, 1);
  end;
end;

procedure TfrmPagamento.LancaVendaNoCaixa(APedido: IGetPedido);
var
  Lancamento: TCaixa;
  Caixa: TMapCaixa;
  VDescricao: String;
begin
  Lancamento := TCaixa.Create;
  Caixa := TMapCaixa.Create(con, 'caixa');
  VDescricao := 'VENDA: ' + TwoFirstsWords(TGetCliente.new(APedido.cliente).nome);
  try
    Lancamento.Data_lancamento := APedido.data;
    Lancamento.Valor           := APedido.valor;
    Lancamento.Parcela         := 0;
    Lancamento.Pedido          := APedido.id;
    Lancamento.Descricao       := VDescricao;
    Lancamento.Pagamento       := APedido.pagamento;
    Lancamento.Tipo            := 'R';
    Caixa.Nulls := True;
    Caixa.Table.IgnoredFields.CommaText := 'status,data_cadastro,projecao';
    Caixa.Add(Lancamento);
    Caixa.Apply;
  finally
    Lancamento.Free;
    Caixa.Free;
  end;
end;

procedure TfrmPagamento.LancaPrevisao(APedido: IGetPedido; AParcela: Integer);
var
  Lancamento: TCaixa;
  Caixa: TMapCaixa;
  VDescricao: String;
  VPagamento: IGetFormaPgto;
begin
  Lancamento := TCaixa.Create;
  Caixa := TMapCaixa.Create(con, 'caixa');
  VPagamento := TGetFormaPgto.new(APedido.pagamento);
  VDescricao := 'PREV. DE REC.: ('+ APedido.id.to_s + ') PARC. '+AParcela.to_s+'/'+APedido.parcelas.to_s;
  try
    if (APedido.pagamento = 6) then
      Lancamento.Data_lancamento := dePrimeiroVencimento.Date
    else
      Lancamento.Data_lancamento := DiaUtilApartirDe(APedido.data + VPagamento.periodo * AParcela);
    Lancamento.Valor           := ((APedido.valor * (1 - VPagamento.taxa))/ APedido.parcelas);
    Lancamento.Parcela         := AParcela;
    Lancamento.Pedido          := APedido.id;
    Lancamento.Descricao       := VDescricao;
    Lancamento.Pagamento       := 0;
    Lancamento.Data_cadastro   := APedido.data;
    Lancamento.Projecao        := 1;
    Lancamento.Tipo            := 'R';
    Caixa.Nulls := True;
    Caixa.Table.IgnoredFields.CommaText := 'status,pagamento';
    Caixa.Add(Lancamento);
    Caixa.Apply;
  finally
    Lancamento.Free;
    Caixa.Free;
  end;
end;

procedure TfrmPagamento.LancaParcelas(APedido: IGetPedido);
var
  Parcela: TParcelas;
  Parcelas: TMapParcelas;
  VData: TDateTime;
  VParcelas: TPlots;
  i: Integer;
begin
  Parcela := TParcelas.Create;
  Parcelas := TMapParcelas.Create(con, 'parcelas');
  VData := dePrimeiroVencimento.Date;
  VParcelas := Parcelar(APedido.valor, APedido.parcelas);
  try
    for i:=1 to APedido.parcelas do
    begin
      VData := MesComercialAdiante(VData);
      Parcela.Pedido := APedido.id;
      Parcela.Data_vencimento := VData;
      Parcela.Parcela := i;
      Parcela.Status := 'A';
      Parcela.Valor_parcela := VParcelas[i-1];
      Parcelas.Add(Parcela);
      Parcelas.Apply;
    end;
  finally
    Parcela.Free;
    Parcelas.Free;
  end;
end;

function TfrmPagamento.FormatDateFontMono(ADate: TDateTime): String;
var
  VYear, VMonth, VDay: word;
  VSpace: String;
begin
  Result := '';
  VSpace := '';
  DecodeDate(ADate, VYear, VMonth, VDay);
  if VDay < 10 then VSpace := ' ';
  if VMonth < 10 then VSpace := VSpace + ' ';
  Result := VSpace + DateToStr(ADate);
end;

function TfrmPagamento.GetClienteIfNeeded(APedido: Integer): Integer;
var
  VCliente: Integer;
begin
  Result := 0;
  MessageDlg('É necessário definir um cliente.'+#13+
             'Será aberta uma janela para a escolha do cliente',
             mtInformation, [mbOK], 0);
  Result := createFormGetTag(TfrmBuscaCliente, frmBuscaCliente);
  if (Result = 0) then
    MessageDlg('Sem definir cliente não é possivel vender a prazo!', mtWarning, [mbOK], 0);
end;

end.

