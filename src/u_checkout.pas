unit u_checkout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, dSQLdbBroker, dUtils, strutils, u_libs, u_models, u_rules,
  u_dm, ACBrNFe, ACBrNFeNotasFiscais, pcnConversao, ACBrIBPTax, pcnNFe,
  pcnConversaoNFe;

type
  TKindMsg = (kdSucess, kdAlert, kdNotify, kdError);

  { TTributos }
  TTributos = record
    Estaduais: Currency;
    Federais: Currency;
    Municipais: Currency;
  end;


  { TfrmCheckout }
  TfrmCheckout = class(TForm)
    IBPT: TACBrIBPTax;
    cbFpgto: TComboBox;
    edValor: TEdit;
    Label1: TLabel;
    lbValorDoPedido: TLabel;
    lbDinheiro: TLabel;
    Label3: TLabel;
    lbValor: TLabel;
    lbValorDoTroco: TLabel;
    lbTroco: TLabel;
    Panel1: TPanel;
    pnMsg: TPanel;
    btnReceber: TSpeedButton;
    Timer: TTimer;
    procedure cbFpgtoChange(Sender: TObject);
    procedure edValorChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure btnReceberClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    procedure ConfiguraNFCe(const VNFCe: TNFe);
    procedure Flash(AMessage: string; AkdMsg: TKindMsg = kdSucess);
    procedure FaturaPedido(APedido, AFormaPgto, AParcelas: integer);
    procedure IterarProdutosNFCe(ADet: TDetCollection; APedido: integer; out ATributos: TTributos);
    procedure PreencherPagamentosNFCe(var Pedido: IGetPedido; var VNFCe: TNFe);
    procedure PreencherTotaisNFCe(const Pedido: IGetPedido; var VNFCe: TNFe);
    procedure PreencherTributosAproximadosNoDANFCe(ATributos: TTributos; var ANFCe: TNFe);
    procedure ValidarNFe(ANF: TNotasFiscais);
    procedure SalvaInfoBD(ADFId: integer);
    procedure SetEmpresasNoDF(ANFCe: TNFe);
    procedure SetDestinatarioNoDF(ANFCe: TNFe; ACliente: integer);
    procedure GeraNFCe(APedido: integer);
    function RegistraDF(const APedido: integer): integer;
    function ValueIn(Value: integer; const Values: array of integer): boolean;
    function EnviarNFe(ANF: TNotasFiscais): Boolean;
    function EnviarNFCe(ANF: TNotasFiscais): Boolean;
  public

  end;

var
  frmCheckout: TfrmCheckout;

implementation

uses
  u_main;

{$R *.lfm}

{ TfrmCheckout }

procedure TfrmCheckout.btnReceberClick(Sender: TObject);
begin
  if ((cbFpgto.ItemIndex = 0) and (edValor.Text <> '')) then
    if ((edValor.Text.to_f * 100) < lbValor.Tag) then
    begin
      Flash('Valor insuficiente para o pagamento!', kdError);
      edValor.SetFocus;
      Abort;
    end;
  btnReceber.Enabled := False;
  try
    GeraNFCe(Tag);
  finally
    btnReceber.Enabled := True;
  end;
end;

procedure TfrmCheckout.FormShow(Sender: TObject);
var
  Pedido: TPedido;
  Pedidos: TMapPedidos;
  Valor: currency;
begin
  {=== Pegar pedido e exibir total na tela ===}
  Pedido := TPedido.Create;
  Pedidos := TMapPedidos.Create(con, 'pedidos');
  try
    Pedido.Id := Self.Tag;
    Pedidos.Get(Pedido);
    Valor := Pedido.Subtotal - Pedido.Desconto + Pedido.Acrescimo;
    lbValor.Tag := trunc(Valor * 100);
    lbValor.Caption := Money(Valor);
  finally
    Pedido.Free;
    Pedidos.Free;
  end;
end;

procedure TfrmCheckout.cbFpgtoChange(Sender: TObject);
begin
  edValor.Visible := cbFpgto.ItemIndex = 0;
  lbDinheiro.Visible := cbFpgto.ItemIndex = 0;
  if cbFpgto.ItemIndex > 0 then
  begin
    lbValorDoTroco.Visible := False;
    lbTroco.Visible := False;
    edValor.Clear;
  end;
end;

procedure TfrmCheckout.edValorChange(Sender: TObject);
begin
  {=== Exibe, caso haja, o valor do troco ===}
  lbTroco.Caption := Money((edValor.Text.to_f) - (lbValor.Tag / 100));
  lbTroco.Visible := not (lbValor.Tag > trunc(edValor.Text.to_f * 100));
  lbValorDoTroco.Visible := lbTroco.Visible;
end;

procedure TfrmCheckout.FormCreate(Sender: TObject);
begin
  IBPT.AbrirTabela(Application.Location + 'impostos.csv');
end;

procedure TfrmCheckout.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = 13) then
    btnReceber.Click;
  if (key = 27) then
    Close;
end;

procedure TfrmCheckout.TimerTimer(Sender: TObject);
begin
  pnMsg.Hide;
  if Timer.Tag = 1 then Close;
end;

procedure TfrmCheckout.ConfiguraNFCe(const VNFCe: TNFe);
begin
  with VNFCe do
  begin
    Ide.tpAmb := dm.nfe.Configuracoes.WebServices.Ambiente;
    Ide.verProc := frmMain.up.GetCurrentVersion;
    Ide.procEmi := peAplicativoContribuinte;
    Ide.finNFe := TpcnFinalidadeNFe.fnNormal;
    Ide.tpImp := TpcnTipoImpressao.tiNFCe;
    Ide.tpNF := TpcnTipoNFe.tnSaida;
    Ide.indPres := pcPresencial;
    Ide.cNF := Random(99999999);
    Ide.serie := 1;
    Ide.natOp := 'VENDA DE MERCADORIA';
    Ide.indFinal := cfConsumidorFinal;
    Ide.dEmi := Now;
    Ide.cUF := UFtoCUF('GO');
    Ide.cMunFG := 5209101;
    Ide.modelo := 65;
    Ide.tpEmis := TpcnTipoEmissao.teNormal;
    if cbFpgto.ItemIndex = 0 then
      Ide.indPag := TpcnIndicadorPagamento.ipVista
    else
      Ide.indPag := TpcnIndicadorPagamento.ipPrazo;
  end;
end;

procedure TfrmCheckout.Flash(AMessage: string; AkdMsg: TKindMsg);
begin
  case AkdMsg of
    kdSucess:
    begin
      pnMsg.Color := $00E6F5D2;
      pnMsg.Font.Color := $00489217;
    end;
    kdNotify:
    begin
      pnMsg.Color := $00FFE0D0;
      pnMsg.Font.Color := $00DD842E;
    end;
    kdAlert:
    begin
      pnMsg.Color := $00DFF8FF;
      pnMsg.Font.Color := $0000A8FF;
    end;
    kdError:
    begin
      pnMsg.Color := $00EFF2FF;
      pnMsg.Font.Color := $000000F7;
      Beep;
    end;
  end;
  pnMsg.Caption := AMessage;
  pnMsg.Show;
  Timer.Enabled := True;
end;

procedure TfrmCheckout.FaturaPedido(APedido, AFormaPgto, AParcelas: integer);
var
  Pedido: TPedido;
  Pedidos: TMapPedidos;
  VCliente: integer;
begin
  VCliente := 0;
  Pedido := TPedido.Create;
  Pedidos := TMapPedidos.Create(con, 'pedidos');
  try
    Pedido.Id := APedido;
    Pedidos.Get(Pedido);
    Pedido.Pagamento := AFormaPgto;
    Pedido.Parcelas := AParcelas;
    Pedido.Status := 'F';

    //ShowMessage('cliente: '+Pedido.Cliente.to_s);
    //if VCliente > 0 then
    //  Pedido.Cliente := VCliente;
    Pedidos.Modify(Pedido);
    Pedidos.Apply;
  finally
    Pedido.Free;
    Pedidos.Free;
  end;
end;

procedure TfrmCheckout.IterarProdutosNFCe(ADet: TDetCollection;
  APedido: integer; out ATributos: TTributos);
var
  qry: TdSQLdbQuery;
  Item: TItensDF;
  i, tab: integer;
  ConverteOk: boolean;
  VTributos: TTributos;
  ex, desc: String;
  VNac, VImp, VEst, VMun: Double;
  Pedido: TPedido;
  Pedidos: TMapPedidos;
begin
  qry := TdSQLdbQuery.Create(con);
  Item := TItensDF.Create;
  qry.SQL.Text := 'select * from itens_df where pedido=' + APedido.to_s;
  try
    qry.Open;
    if not qry.IsEmpty then
    begin
      qry.First;

      {=== Define as variáveis de tributos para informação (IBPT) ===}
      VTributos.Federais   := 0;
      VTributos.Estaduais  := 0;
      VTributos.Municipais := 0;

      for i := 1 to qry.RowsAffected do
        with ADet.Add do
        begin
          VNac := 0;
          VImp := 0;
          VEst := 0;
          VMun := 0;
          dUtils.dGetFields(Item, qry.Fields);
          Prod.nItem := i;
          Prod.cProd := Item.Id.to_s;
          Prod.cEAN := Item.Ean13;
          Prod.cEANTrib := Item.Ean13;
          Prod.xProd := Item.Descricao;
          Prod.NCM := Item.Ncm;
          Prod.uCom := Item.Unidade;
          Prod.uTrib := Item.Unidade;
          Prod.qCom := Item.Quantidade;
          Prod.qTrib := Item.Quantidade;
          Prod.vUnCom := Item.Valor;
          Prod.vProd := Item.Valor  * Item.Quantidade;
          Prod.vUnTrib := Item.Valor;
          Prod.vDesc := Item.Desconto;

          Imposto.ICMS.orig := TpcnOrigemMercadoria.oeNacional;

          if Trim(Item.Tributacao) = 'F' then
          begin
            Prod.CFOP := '5405';
            Prod.CEST := Item.Cest;
            Imposto.ICMS.CSOSN := StrToCSOSNIcms(ConverteOk, '500');
          end
          else
          begin
            Prod.CFOP := '5102';
            Imposto.ICMS.CSOSN := StrToCSOSNIcms(ConverteOk, '102');
          end;

          Imposto.ICMS.pCredSN := 0.00;
          Imposto.ICMS.vCredICMSSN := 0.00;

          Imposto.PIS.CST := StrToCSTPIS(ConverteOk, '99');
          Imposto.PIS.vBC := 0.00;
          Imposto.PIS.pPIS := 0.00;
          Imposto.PIS.vPIS := 0.00;

          Imposto.COFINS.CST := StrToCSTCOFINS(ConverteOk, '99');
          Imposto.COFINS.vBC := 0.00;
          Imposto.COFINS.pCOFINS := 0.00;
          Imposto.COFINS.vCOFINS := 0.00;

          try
            IBPT.Procurar(Item.Ncm, ex, desc, tab, vNac, VImp, VEst, VMun, False);
            VTributos.Federais   :=+ ((Item.Quantidade * Item.Valor) * ((VImp + VNac)/100));
            VTributos.Estaduais  :=+ ((Item.Quantidade * Item.Valor) * (VEst/100));
            VTributos.Municipais :=+ ((Item.Quantidade * Item.Valor) * (VMun/100));
          except
            VTributos.Federais   :=+ 0;
            VTributos.Estaduais  :=+ 0;
            VTributos.Municipais :=+ 0;
          end;
          qry.Next;
        end;
      ATributos := VTributos;
      Pedido := TPedido.Create;
      Pedidos := TMapPedidos.Create(con, 'pedidos');
      try
        Pedido.Id := APedido;
        Pedidos.Get(Pedido);
        Pedido.Tot_imp_federais   := VTributos.Federais;
        Pedido.Tot_imp_estaduais  := VTributos.Estaduais;
        Pedido.Tot_imp_municipais := VTributos.Municipais;
        Pedidos.Modify(Pedido);
        Pedidos.Apply;
      finally
        Pedido.Free;
        Pedidos.Free;
      end;
    end;
  finally
    Item.Free;
    qry.Free;
  end;
end;

procedure TfrmCheckout.PreencherPagamentosNFCe(var Pedido: IGetPedido; var VNFCe: TNFe);
begin
  VNFCe.pag.Add;
  if (cbFpgto.ItemIndex > 0) then VNFCe.pag.Items[0].tpIntegra := tiPagNaoIntegrado;
  case cbFpgto.ItemIndex of
    0: VNFCe.pag.Items[0].tPag := TpcnFormaPagamento.fpDinheiro;
    1: VNFCe.pag.Items[0].tPag := TpcnFormaPagamento.fpCartaoCredito;
    2: VNFCe.pag.Items[0].tPag := TpcnFormaPagamento.fpCartaoDebito;
    3: VNFCe.pag.Items[0].tPag := TpcnFormaPagamento.fpOutro;
    4: VNFCe.pag.Items[0].tPag := TpcnFormaPagamento.fpCreditoLoja;
  end;
  VNFCe.pag.Items[0].vPag := Pedido.valor;
end;

procedure TfrmCheckout.PreencherTotaisNFCe(const Pedido: IGetPedido; var VNFCe: TNFe);
begin
  VNFCe.Total.ICMSTot.vBC := 0.00;
  VNFCe.Total.ICMSTot.vICMS := 0.00;
  VNFCe.Total.ICMSTot.vFrete := 0.00;
  VNFCe.Total.ICMSTot.vSeg := 0.00;
  VNFCe.Total.ICMSTot.vOutro := 0.00;
  VNFCe.Total.ICMSTot.vDesc := Pedido.desconto;
  VNFCe.Total.ICMSTot.vBCST := 0.00;
  VNFCe.Total.ICMSTot.vST := 0.00;
  VNFCe.Total.ICMSTot.vIPI := 0.00;
  VNFCe.Total.ICMSTot.vPIS := 0.00;
  VNFCe.Total.ICMSTot.vCOFINS := 0.00;
  VNFCe.Total.ICMSTot.vProd := Pedido.subtotal;
  VNFCe.Total.ICMSTot.vNF := Pedido.valor;
end;

procedure TfrmCheckout.ValidarNFe(ANF: TNotasFiscais);
var
  VErrosRegraNegocio: string;
begin
  try
    ANF.Validar;
  except
    on E: Exception do
    begin
      raise Exception.Create(IfThen(
        ANF.Items[0].ErroValidacao <> '', ANF.Items[0].ErroValidacao,
        E.Message));
    end;
  end;
  ANF.ValidarRegrasdeNegocios(VErrosRegraNegocio);
  if VErrosRegraNegocio <> '' then
    raise Exception.Create(VErrosRegraNegocio);
end;

function TfrmCheckout.EnviarNFe(ANF: TNotasFiscais): Boolean;
var
  NumeroLote, VMsgRetorno, MsgMotivoDenegacao: string;
  VStatusNota: integer;
begin
  Result := False;
  NumeroLote := FormatDateTime('yyyymmddhhmmss', NOW);
  if dm.nfe.Enviar(NumeroLote, False, True) then
  begin
    VStatusNota := ANF.Items[0].NFe.procNFe.cStat;
    VMsgRetorno := '';

    SalvaInfoBD(ANF.Items[0].NFe.Ide.nNF);

    if ValueIn(VStatusNota, [100, 150, 110, 301, 302]) then
    begin
      case VStatusNota of
        100, 150:
        begin
          Result := True;
          VMsgRetorno := 'Nota fiscal autorizada: ' +
            Format('Nº: %9.9d - Data: %s', [ANF.Items[0].NFe.Ide.nNF,
            FormatDateTime('dd/mm/yyyy', ANF.Items[0].NFe.Ide.dEmi)]);
          FaturaPedido(Tag, cbFpgto.ItemIndex, 1);
          dm.nfe.DANFE.ImprimirDANFE();
        end;
        110, 301, 302:
        begin
          case VStatusNota of
            110: MsgMotivoDenegacao := '110 - Nota fiscal denegada';
            301: MsgMotivoDenegacao := '301 - Irregularidade fiscal do emitente';
            302: MsgMotivoDenegacao := '302 - Irregularidade fiscal do destinat�rio';
          end;

          VMsgRetorno := Format('NF: %9.9d  - Motivo: %s',
            [ANF.Items[0].NFe.Ide.nNF, MsgMotivoDenegacao]);
        end;
      end;
    end
    else
    begin
      VMsgRetorno :=
        Format('Nº: %9.9d - ', [ANF.Items[0].NFe.Ide.nNF]) +
        string(ANF.Items[0].Msg);
    end;
    if VMsgRetorno <> '' then
      Flash(VMsgRetorno);
  end;
end;

function TfrmCheckout.EnviarNFCe(ANF: TNotasFiscais): Boolean;
var
  NumeroLote, VMsgRetorno, MsgMotivoDenegacao: String;
  VStatusNota: Integer;
begin
  Result := False;
  NumeroLote := FormatDateTime('yyyymmddhhmmss', NOW);
  try
    if dm.nfe.Enviar(NumeroLote, False, True) then
    begin
      VStatusNota := ANF.Items[0].NFe.procNFe.cStat;
      VMsgRetorno := '';

      SalvaInfoBD(ANF.Items[0].NFe.Ide.nNF);

      if ValueIn(VStatusNota, [100, 150, 110, 301, 302]) then
      begin
        case VStatusNota of
          100, 150:
          begin
            Result := True;
            VMsgRetorno := 'Nota fiscal autorizada: ' +
              Format('Nº: %9.9d - Data: %s', [ANF.Items[0].NFe.Ide.nNF,
              FormatDateTime('dd/mm/yyyy', ANF.Items[0].NFe.Ide.dEmi)]);
            FaturaPedido(Tag, cbFpgto.ItemIndex, 1);
            dm.nfe.DANFE.ImprimirDANFE();
          end;
          110, 301, 302:
          begin
            case VStatusNota of
              110: MsgMotivoDenegacao := '110 - Nota fiscal denegada';
              301: MsgMotivoDenegacao := '301 - Irregularidade fiscal do emitente';
              302: MsgMotivoDenegacao := '302 - Irregularidade fiscal do destinat�rio';
            end;

            VMsgRetorno := Format('NF: %9.9d  - Motivo: %s',
              [ANF.Items[0].NFe.Ide.nNF, MsgMotivoDenegacao]);
          end;
        end;
      end
      else
      begin
        VMsgRetorno :=
          Format('Nº: %9.9d - ', [ANF.Items[0].NFe.Ide.nNF]) +
          string(ANF.Items[0].Msg);
      end;
      if VMsgRetorno <> '' then
        Flash(VMsgRetorno);
    end;

  except
    on E: Exception do
    begin
    if (pos('12007', E.Message) > 0) or // erro de conexão
       (pos('12002', E.Message) > 0) or // timeout
       (pos('12029', E.Message) > 0) or // limite de tempo de conexão
       (pos('ERRO HTTP:', UpperCase(E.Message)) > 0) or // erro http genérico
       (pos('ERRO NAO CATALOGADO', UpperCase(E.Message)) > 0) then // erros de tratamento do webservice
    begin
      {=== Enia em Contigência Offline ===}
      if FileExists(dm.nfe.NotasFiscais.Items[0].CalcularNomeArquivoCompleto()) then
        DeleteFile(dm.nfe.NotasFiscais.Items[0].CalcularNomeArquivoCompleto());
      dm.nfe.Configuracoes.Geral.FormaEmissao := teOffLine; //muda pra off line
      ANF.Items[0].NFe.Ide.tpEmis := teOffLine;
      ANF.Items[0].NFe.Ide.dhCont := Now;
      ANF.Items[0].NFe.Ide.xJust  := 'Falha ao se conectar com a internet';
      ANF.GerarNFe;
      ANF.Assinar;
      ANF.Validar;
      SalvaInfoBD(ANF.Items[0].NFe.Ide.nNF);
      try
        dm.nfe.DANFE.ViaConsumidor := false;
        ANF.Imprimir;
      finally
        dm.nfe.DANFE.ViaConsumidor := True;
        ANF.Imprimir;
        FaturaPedido(Tag, cbFpgto.ItemIndex, 1);
        Flash('NFCe emitida em contingência', kdAlert);
        Result := True;
      end;
    end
    else
      raise;
  end;
end;

end;

procedure TfrmCheckout.PreencherTributosAproximadosNoDANFCe(
  ATributos: TTributos; var ANFCe: TNFe);
begin
  ANFCe.InfAdic.infCpl :=  'Voce pagou aproximadamente: ' + LineBreak +
                           IfThen(ATributos.Federais > 0, 'R$ ' + FormatFloat('#,###,##0.00', ATributos.Federais) + ' de tributos federais' + LineBreak, '') +
                           IfThen(ATributos.Estaduais > 0, 'R$ ' + FormatFloat('#,###,##0.00', ATributos.Estaduais) + ' de tributos estaduais' + LineBreak , '') +
                           IfThen(ATributos.Municipais > 0, 'R$ ' + FormatFloat('#,###,##0.00', ATributos.Municipais) + ' de tributos municipais' + LineBreak , '') +
                           'Fonte: ' + IBPT.Fonte + ' - Chave: ' + IBPT.ChaveArquivo;

  //dm.nfe.DANFE.vTribFed := ATributos.Federais;
  //dm.nfe.DANFE.vTribEst := ATributos.Estaduais;
  //dm.nfe.DANFE.vTribMun := ATributos.Municipais;
  //dm.nfe.DANFE.FonteTributos := IBPT.Fonte;
  //dm.nfe.DANFE.ChaveTributos := IBPT.ChaveArquivo;
  //dm.nfe.DANFE.ImprimirTributos := True;
end;

  //if dm.nfe.Enviar(NumeroLote, False) then
  //begin
  //  VStatusNota := ANF.Items[0].NFe.procNFe.cStat;
  //  VMsgRetorno := '';
  //
  //  SalvaInfoBD(ANF.Items[0].NFe.Ide.nNF);
  //
  //  if ValueIn(VStatusNota, [100, 150, 110, 301, 302]) then
  //  begin
  //    case VStatusNota of
  //      100, 150:
  //      begin
  //        Result := True;
  //        VMsgRetorno := 'Nota fiscal autorizada: ' +
  //          Format('Nº: %9.9d - Data: %s', [ANF.Items[0].NFe.Ide.nNF,
  //          FormatDateTime('dd/mm/yyyy', ANF.Items[0].NFe.Ide.dEmi)]);
  //        FaturaPedido(Tag, cbFpgto.ItemIndex, 1);
  //        {$IFNDEF Desenvolvimento}
  //           dm.nfe.DANFE.ImprimirDANFE();
  //        {$ENDIF}
  //      end;
  //      110, 301, 302:
  //      begin
  //        case VStatusNota of
  //          110: MsgMotivoDenegacao := '110 - Nota fiscal denegada';
  //          301: MsgMotivoDenegacao := '301 - Irregularidade fiscal do emitente';
  //          302: MsgMotivoDenegacao := '302 - Irregularidade fiscal do destinat�rio';
  //        end;
  //
  //        VMsgRetorno := Format('NF: %9.9d  - Motivo: %s',
  //          [ANF.Items[0].NFe.Ide.nNF, MsgMotivoDenegacao]);
  //      end;
  //    end;
  //  end
  //  else
  //  begin
  //    VMsgRetorno :=
  //      Format('Nº: %9.9d - ', [ANF.Items[0].NFe.Ide.nNF]) +
  //      string(ANF.Items[0].Msg);
  //  end;
  //  if VMsgRetorno <> '' then
  //    Flash(VMsgRetorno);
  //end;

procedure TfrmCheckout.SalvaInfoBD(ADFId: integer);
var
  DF: TDocumentoFiscal;
  DFs: TMapDocumentoFiscal;
  VNota: TNFe;
begin
  DF := TDocumentoFiscal.Create;
  DFs := TMapDocumentoFiscal.Create(con, 'documento_fiscal');
  VNota := dm.nfe.NotasFiscais.Items[0].NFe;
  try
    DF.Id := ADFId;
    DFs.Get(DF);
    DF.tpAmb    := dm.nfe.Configuracoes.WebServices.AmbienteCodigo;
    DF.Path_xml := dm.nfe.NotasFiscais.Items[0].CalcularNomeArquivoCompleto();
    DF.tpEmis   := TpEmisToStr(dm.nfe.NotasFiscais.Items[0].NFe.Ide.tpEmis).to_i;
    DF.nProt    := VNota.procNFe.nProt;
    DF.chNFe    := dm.nfe.NotasFiscais.Items[0].NumID;
    if dm.nfe.NotasFiscais.Items[0].NFe.Ide.tpEmis = teOffLine then
      DF.dhEmis   := VNota.Ide.dhCont
    else
      DF.dhEmis   := VNota.Ide.dEmi;

    DF.dhRecbto := VNota.procNFe.dhRecbto;
    DF.xMotivo  := VNota.procNFe.xMotivo;
    DF.cStat    := VNota.procNFe.cStat;
    DF.Valor    := VNota.Total.ICMSTot.vNF;
    DF.Serie    := VNota.Ide.serie;
    DFs.Modify(DF);
    DFs.Apply;
  finally
    DF.Free;
    DFs.Free;
  end;
end;

function TfrmCheckout.RegistraDF(const APedido: integer): integer;
var
  DF: TDocumentoFiscal;
  DFs: TMapDocumentoFiscal;
begin
  DF := TDocumentoFiscal.Create;
  DFs := TMapDocumentoFiscal.Create(con, 'documento_fiscal');
  try
    DF.Pedido := APedido;
    if not DFs.Find(DF, 'pedido=:pedido') then
    begin
      DF.Pedido := APedido;
      DFs.Get(DF);
      DFs.Nulls := True;
      DFs.Table.IgnoredFields.CommaText := 'modelo,tpemis,finnfe,tpamb';
      DFs.Add(DF);
      DFs.Apply;
      DF.Pedido := APedido;
      DFs.Find(DF, 'pedido=:pedido');
    end;
    Result := DF.Id;
  finally
    DF.Free;
    DFs.Free;
  end;
end;

function TfrmCheckout.ValueIn(Value: integer; const Values: array of integer): boolean;
var
  I: integer;
begin
  Result := False;
  for I := Low(Values) to High(Values) do
  begin
    if Value = Values[I] then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TfrmCheckout.SetEmpresasNoDF(ANFCe: TNFe);
var
  Empresa: TEmpresa;
  Empresas: TMapEmpresas;
begin
  Empresa := TEmpresa.Create;
  Empresas := TMapEmpresas.Create(con, 'empresa');
  try
    Empresa.Id := 1;
    Empresas.Get(Empresa);
    if (Empresa.Cnpj.raw_numbers <> '') then
    begin
      with ANFCe do
      begin
        Emit.CRT := TpcnCRT.crtSimplesNacional;
        Emit.xNome := Empresa.Razao;
        Emit.xFant := Empresa.Fantasia;
        Emit.CNPJCPF := Empresa.Cnpj;
        Emit.IE := Empresa.Insc;
        Emit.CNAE := Empresa.Cnae_1;
        Emit.EnderEmit.fone := Empresa.Telefone;
        Emit.EnderEmit.xLgr := Empresa.Endereco;
        Emit.EnderEmit.nro := Empresa.Numero.to_s;
        Emit.EnderEmit.xCpl := Empresa.Complemento;
        Emit.EnderEmit.xBairro := Empresa.Bairro;
        Emit.EnderEmit.xMun := Empresa.Cidade;
        Emit.EnderEmit.cMun := 5209101;
        Emit.EnderEmit.UF := 'GO';
        Emit.EnderEmit.CEP := 75600000;
        Emit.enderEmit.cPais := 1058;
        Emit.enderEmit.xPais := 'BRASIL';
      end;
    end;
  finally
    Empresa.Free;
    Empresas.Free;
  end;
end;

procedure TfrmCheckout.SetDestinatarioNoDF(ANFCe: TNFe; ACliente: integer);
var
  Cliente: IGetCliente;
begin
  ANFCe.Dest.indIEDest := inNaoContribuinte;
  if (ACliente > 0) then
  begin
    Cliente := TGetCliente.new(ACliente);
    with ANFCe do
    begin
      Dest.xNome := Cliente.nome;
      ShowMessage('Nome: '+Cliente.nome);
      Dest.CNPJCPF := Cliente.cpf_cnpj;
      Dest.EnderDest.Fone := Cliente.celular;
      Dest.EnderDest.xLgr := Cliente.endereco;
      if Length(Cliente.cpf_cnpj.raw_numbers) = 14 then
        Dest.indIEDest := inContribuinte;
    end;
  end;
end;

procedure TfrmCheckout.GeraNFCe(APedido: integer);
var
  VNFCe: TNFe;
  DF: TDocumentoFiscal;
  DFs: TMapDocumentoFiscal;
  VDFId: integer;
  Pedido: IGetPedido;
  VNFs: TNotasFiscais;
  VTributos: TTributos;
begin
  Flash('Aguarde!', kdAlert);
  Pedido := TGetPedido.new(APedido);
  DF := TDocumentoFiscal.Create;
  DFs := TMapDocumentoFiscal.Create(con, 'documento_fiscal');
  try
    VDFId := RegistraDF(APedido);
    {=== Abre a NFCe ===}
    dm.nfe.NotasFiscais.Clear;
    VNFs := dm.nfe.NotasFiscais;
    VNFCe := dm.nfe.NotasFiscais.Add.NFe;
    VNFCe.Ide.nNF := VDFId;
    VNFCe.Det.Clear;
    ConfiguraNFCe(VNFCe);
    {=== identificação do Emitente ===}
    SetEmpresasNoDF(VNFCe);
    {=== Identificação do Destinatário ===}
    SetDestinatarioNoDF(VNFCe, Pedido.cliente);
    {=== Registar intens na NFCe ===}
    IterarProdutosNFCe(VNFCe.Det, APedido, VTributos);
    {=== Preencher tributos no DANFCe ===}
    PreencherTributosAproximadosNoDANFCe(VTributos, VNFCe);
    {=== Informações de Pagamento ===}
    PreencherPagamentosNFCe(Pedido, VNFCe);
    {=== Informações de Totais da Nota ===}
    PreencherTotaisNFCe(Pedido, VNFCe);
    {=== Configurações padrão NFCe ===}
    VNFCe.Transp.modFrete := TpcnModalidadeFrete.mfSemFrete;
    {=== Assinar a NFCe ===}
    VNFs.Assinar;
    {=== Validar a NFCe ===}
    ValidarNFe(VNFs);
    {=== Enviar NFCe ===}
    if EnviarNFCe(VNFs) then Timer.Tag := 1;
  finally
    DF.Free;
    DFs.Free;
  end;
end;

end.
