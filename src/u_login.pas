unit u_login;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, ActnList, PinForm, u_dm, ghSQL, VersionSupport;

type

  { TfrmLogin }

  TfrmLogin = class(TForm)
    aclLogin: TActionList;
    acFechar: TAction;
    btnEntrar: TSpeedButton;
    edPassword: TEdit;
    edUser: TComboBox;
    Image1: TImage;
    lbVersao: TLabel;
    lbMsg: TLabel;
    procedure acFecharExecute(Sender: TObject);
    procedure btnEntrarClick(Sender: TObject);
    procedure edPasswordKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
  private
    procedure shapeForm(AControl: TWinControl);
  public
    class function Execute: boolean;
  end;

var
  frmLogin: TfrmLogin;
  attemps: Integer;

implementation

{$R *.lfm}

{ TfrmLogin }

procedure TfrmLogin.btnEntrarClick(Sender: TObject);
var
  User: TghSQLTable;
begin
  User := Co.Tables['USUARIOS'];
  User.Where('LOGIN='''+edUser.Text+'''').Open;
  if edPassword.Text = User['SENHA'].AsString then
  begin
    dm.Tag := User['ID'].AsInteger;
    ModalResult := mrOk
  end
  else
  begin
    if attemps < 2 then
    begin
      lbMsg.Caption := 'Senha incorreta. Tente novamente!';
      attemps := attemps + 1;
      edPassword.Clear;
      edPassword.SetFocus;
      Abort;
    end;
    ModalResult := mrAbort;
  end;
end;

procedure TfrmLogin.acFecharExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmLogin.edPasswordKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    key := #0;
    btnEntrar.Click;
  end;
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
var
  User: TghSQLTable;
begin
  lbVersao.Caption := GetFileVersion;
  attemps := 0;
  User := Co.Tables['USUARIOS'];
  User.Where('ID > 0').Open;
  User.First;
  while not User.EOF do
  begin
    edUser.Items.Add(User['LOGIN'].AsString);
    User.Next;
  end;
  User.Close;
  edUser.ItemIndex := 0;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  shapeForm(Self);
  edPassword.SetFocus;
end;

procedure TfrmLogin.imgCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmLogin.shapeForm(AControl: TWinControl);
var
  VBitmap: TBitmap;
begin
  VBitmap:= TBitmap.Create;
  try
    VBitmap.Monochrome := True;
    VBitmap.Height := AControl.Height;
    VBitmap.Width  := AControl.Width;
    with VBitmap.Canvas do
	  begin
      Brush.Color := clBlack;
      FillRect(0, 0, AControl.Width, AControl.Height);
      Brush.Color := clWhite;
      Ellipse(0, 0, AControl.Width, AControl.Height);
    end;
    AControl.SetShape(VBitmap);
  finally
    VBitmap.Free;
  end;
end;

class function TfrmLogin.Execute: boolean;
begin
  with TfrmLogin.Create(nil) do
    try
      Result := ShowModal = mrOk;
    finally
      Free;
    end;
end;

end.

