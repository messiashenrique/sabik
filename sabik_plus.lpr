program sabik_plus;

{$mode delphi}

uses

  {$IFDEF DEBUG}
    heaptrc,
  {$ENDIF}
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, u_main, u_libs, u_usuarios, u_models, u_fornecedores,
  u_dm, u_clientes, u_grupos, u_login, u_produtos, u_rules, u_busca_grupo,
  u_entradas, u_busca_produto, u_vendas, u_busca_cliente, u_pagamento,
  u_dfs, u_relatorios, lazreportpdfexport, u_gateway, u_config, u_caixa,
  u_recebimentos, u_checkout;

{$R *.res}

begin
  Application.Title := 'Sabik Plus';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmMain, frmMain);
  if TfrmLogin.Execute then
  begin
    Application.Run;
  end
end.

