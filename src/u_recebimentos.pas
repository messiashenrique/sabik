unit u_recebimentos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, Buttons, u_models, u_libs;

type

  { TfrmRecebimentos }

  TfrmRecebimentos = class(TForm)
    btnReceber: TBitBtn;
    deDataRecebimento: TDateEdit;
    edValor: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure btnReceberClick(Sender: TObject);
    procedure edValorKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    procedure GetParcela(AId: Integer);
    procedure RecebeParcela(AId: Integer; AValue: Currency);
  public
    { public declarations }
  end;

var
  frmRecebimentos: TfrmRecebimentos;

implementation

{$R *.lfm}

{ TfrmRecebimentos }

procedure TfrmRecebimentos.FormCreate(Sender: TObject);
begin
  deDataRecebimento.Date := Date;
end;

procedure TfrmRecebimentos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 27) then Close;
end;

procedure TfrmRecebimentos.edValorKeyPress(Sender: TObject; var Key: char);
begin
  Key := OnlyKeyMoney(Key);
end;

procedure TfrmRecebimentos.btnReceberClick(Sender: TObject);
begin
  if edValor.Text.to_f > 0 then
    RecebeParcela(Tag, edValor.Text.to_f);
  Close;
end;

procedure TfrmRecebimentos.FormShow(Sender: TObject);
begin
  GetParcela(Tag);
  edValor.SetFocus;
end;

procedure TfrmRecebimentos.GetParcela(AId: Integer);
var
  Parcela: TParcelas;
  Parcelas: TMapParcelas;
begin
  Parcela := TParcelas.Create;
  Parcelas := TMapParcelas.Create(con, 'parcelas');
  try
    Parcela.Id := AId;
    Parcelas.Get(Parcela);
    edValor.Text := (Parcela.Valor_parcela - Parcela.Valor_pagamento).to_m;
  finally
    Parcelas.Free;
    Parcela.Free;
  end;
end;

procedure TfrmRecebimentos.RecebeParcela(AId: Integer; AValue: Currency);
var
  Parcela: TParcelas;
  Parcelas: TMapParcelas;
begin
  Parcela := TParcelas.Create;
  Parcelas := TMapParcelas.Create(con, 'parcelas');
  try
    Parcela.Id := AId;
    Parcelas.Get(Parcela);
    if ((Parcela.Valor_pagamento + AValue) >= Parcela.Valor_parcela) then
    Parcela.Status := 'P';
    Parcela.Valor_pagamento := (Parcela.Valor_pagamento + AValue);
    Parcela.Data_pagamento := deDataRecebimento.Date;
    Parcelas.Modify(Parcela);
    Parcelas.Apply;
  finally
    Parcelas.Free;
    Parcela.Free;
  end;
end;

end.

