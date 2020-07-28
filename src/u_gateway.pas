unit u_gateway;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, u_rules, u_libs, fphttpclient;

  function UploadBackups(AFileBackup: String): Boolean;

implementation

function UploadBackups(AFileBackup: String): Boolean;
var
  S: TStringStream;
  Vars: TStringList;
  VInfo: IGetInfo;
begin
  Result := False;
  with TFPHTTPClient.Create(nil) do
  begin
    S := TStringStream.Create('');
    try
      Vars := TStringList.Create;
      try
        VInfo := TGetInfo.new;
        Vars.Add('app=sabik_plus');
        Vars.Add('id='+ VInfo.id_gateway.to_s);
        Vars.Add('token='+ VInfo.token);
        FileFormPost('http://chocobits.com.br/backups', Vars, 'upload', AFileBackup, S);
        //FileFormPost('http://10.0.2.2:9393/backups', Vars, 'upload', AFileBackup, S);
      finally
        Vars.Free;
      end;
    finally
      Result := UpperCase(S.DataString) = 'SUCESSO';
      S.Free
    end;
  end;
end;

end.

