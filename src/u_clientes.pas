unit u_clientes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, ComCtrls, ActnList, EditBtn, ghSQL, dSQLdbBroker,
  u_models, u_libs, pingrid, strutils, dUtils;

{ TfrmClientes }

type
  TKindMsg = (kdSucess, kdAlert, kdNotify, kdError);

  TfrmClientes = class(TForm)
    btnNew: TBitBtn;
    btnAdd: TBitBtn;
    btnCancel: TBitBtn;
    btnEdit: TBitBtn;
    btnRemove: TBitBtn;
    btnSave: TBitBtn;
    deAniversario: TDateEdit;
    edBairro: TEdit;
    edCel1: TEdit;
    edCel2: TEdit;
    edCep: TEdit;
    edCidade: TEdit;
    edCpf: TEdit;
    edEmail: TEdit;
    edEndereco: TEdit;
    edNome: TEdit;
    edRg: TEdit;
    edSearch: TEdit;
    edTel1: TEdit;
    edTel2: TEdit;
    edUF: TEdit;
    grid: TPinGrid;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    imgl: TImageList;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lbTitulo: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbCod: TLabel;
    lbDataCadastro: TLabel;
    mmObs: TMemo;
    nbCrud: TNotebook;
    pnDetails: TPanel;
    pnMsg: TPanel;
    pgDetails: TPage;
    pgGrid: TPage;
    pnControles: TPanel;
    pnRotulo: TPanel;
    pnTop: TPanel;
    sb: TStatusBar;
    Timer: TTimer;
    procedure btnAddClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure edCel1Exit(Sender: TObject);
    procedure edCepExit(Sender: TObject);
    procedure edCpfExit(Sender: TObject);
    procedure edCel2Exit(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edTel1Exit(Sender: TObject);
    procedure edTel2Exit(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure gridDblClick(Sender: TObject);
    procedure gridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure pgDetailsBeforeShow({%H-}ASender: TObject; {%H-}ANewPage: TPage;
      {%H-}ANewIndex: Integer);
    procedure pgGridBeforeShow({%H-}ASender: TObject; {%H-}ANewPage: TPage;
      {%H-}ANewIndex: Integer);
    procedure sbDrawPanel({%H-}StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure TimerTimer(Sender: TObject);
  private
    procedure ClearFields; virtual;
    procedure GoBackToGrid;
    procedure Search(AScript: String);
    procedure SearchDefault; virtual;
    procedure SetControls(AOpen: Boolean = False); virtual;
    procedure GetRegister(AId: Integer);
    procedure AddRegister;
    procedure EditRegister;
    procedure RemoveRegister;
    procedure SaveRegister;
    procedure CancelRegister;
    procedure SetSearch;
    procedure Flash(AMessage: String; AkdMsg: TKindMsg = kdSucess);
    function Validates: Boolean;
  public
    { public declarations }
  end;

var
  frmClientes: TfrmClientes;

implementation

{$R *.lfm}

{ TfrmClientes }

procedure TfrmClientes.btnNewClick(Sender: TObject);
begin
  AddRegister;
end;

procedure TfrmClientes.btnAddClick(Sender: TObject);
begin
  AddRegister;
end;

procedure TfrmClientes.btnCancelClick(Sender: TObject);
begin
  CancelRegister;
end;

procedure TfrmClientes.btnEditClick(Sender: TObject);
begin
  EditRegister;
end;

procedure TfrmClientes.btnRemoveClick(Sender: TObject);
begin
  RemoveRegister;
end;

procedure TfrmClientes.btnSaveClick(Sender: TObject);
begin
  SaveRegister;
end;

procedure TfrmClientes.edCel1Exit(Sender: TObject);
begin
  edCel1.Text := edCel1.Text.maskPhone;
end;

procedure TfrmClientes.edCepExit(Sender: TObject);
begin
  edCep.Text := edCep.Text.maskCep;
end;

procedure TfrmClientes.edCpfExit(Sender: TObject);
begin
  edCpf.Text := edCpf.Text.maskCpfCnpj;
end;

procedure TfrmClientes.edCel2Exit(Sender: TObject);
begin
  edCel2.Text := edCel2.Text.maskPhone;
end;

procedure TfrmClientes.edSearchChange(Sender: TObject);
var
  p: String;
begin
  p := '''%'+UpperCase(edSearch.Text)+'%''';
  if (Length(edSearch.Text) > 0) then
    Search('select id, nome, cpf_cnpj, telefone_1, celular_1 from clientes where '+
           '(id>0) and ((nome like '+p+') or (cpf_cnpj like '+p+') or '+
           '(telefone_1 like '+p+') or (celular_1 like '+p+'))')
  else
    SearchDefault;
end;

procedure TfrmClientes.edSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((key = 40) or (Key = 13)) and (grid.RowCount > 1) then grid.SetFocus;
end;

procedure TfrmClientes.edTel1Exit(Sender: TObject);
begin
  edTel1.Text := edTel1.Text.maskPhone;
end;

procedure TfrmClientes.edTel2Exit(Sender: TObject);
begin
  edTel2.Text := edTel2.Text.maskPhone;
end;

procedure TfrmClientes.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 114) then SetSearch;      {===F3===}
  if (key = 116) then AddRegister;    {===F5===}
  if (key = 117) then EditRegister;   {===F6===}
  if (key = 119) then RemoveRegister; {===F8===}
  if (key = 121) then SaveRegister;   {===F10===}
  if (key = 27)  then CancelRegister; {===Esc===}
end;

procedure TfrmClientes.FormShow(Sender: TObject);
begin
  SearchDefault;
  edSearch.SetFocus;
end;

procedure TfrmClientes.gridDblClick(Sender: TObject);
begin
  if (grid.RowCount > 1) and (grid.Row > 0) then
  begin
    pgDetails.Tag := grid.TagCell[0, grid.Row];
    pgDetails.Show;
  end;
end;

procedure TfrmClientes.gridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 13) and (grid.RowCount > 1) and (grid.Row > 0) then
  begin
    pgDetails.Tag := grid.TagCell[0, grid.Row];
    pgDetails.Show;
  end;
end;

procedure TfrmClientes.pgDetailsBeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
begin
  GetRegister(pgDetails.Tag);
end;

procedure TfrmClientes.pgGridBeforeShow(ASender: TObject; ANewPage: TPage;
  ANewIndex: Integer);
begin
  searchDefault;
end;

procedure TfrmClientes.sbDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
begin
  if (Panel.Index = 0) then imgl.Draw(sb.Canvas, Rect.Left, Rect.Top, 5);
end;

procedure TfrmClientes.TimerTimer(Sender: TObject);
begin
  pnMsg.Hide;
end;

procedure TfrmClientes.ClearFields;
begin
  {=== Limpa os control ue estiverem em pgDetails ===}
  lbCod.Caption          := '';
  lbDataCadastro.Caption := '';
  deAniversario.Clear;
  edCpf.Clear;
  edRg.Clear;
  edNome.Clear;
  edTel1.Clear;
  edTel2.Clear;
  edCel1.Clear;
  edCel2.Clear;
  edEndereco.Clear;
  edBairro.Clear;
  edCep.Clear;
  edCidade.Clear;
  edUF.Clear;
  edEmail.Clear;
  mmObs.Clear;
end;

procedure TfrmClientes.GoBackToGrid;
begin
  setControls;
  pgGrid.Show;
  edSearch.SetFocus;
end;

procedure TfrmClientes.Search(AScript: String);
var
  i: Integer;
  qry: TdSQLdbQuery;
  Cliente: TCliente;
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
          grid.Cells[0, i]   := Cliente.Id.to_s;
          grid.Cells[1, i]   := Cliente.Nome;
          grid.Cells[2, i]   := Cliente.Cpf_cnpj.maskCpfCnpj;
          grid.Cells[3, i]   := Cliente.Telefone_1.maskPhone;
          grid.Cells[4, i]   := Cliente.Celular_1.maskPhone;
          qry.Next;
        end;
      end
      else
        grid.RowCount := 1;
    finally
      Cliente.Free;
      qry.Free;
    end;
end;

procedure TfrmClientes.SearchDefault;
begin
  {=== Faz uma busca padrão ===}
  Search('select id, nome, cpf_cnpj, telefone_1, celular_1 from clientes where id>0');
end;

procedure TfrmClientes.SetControls(AOpen: Boolean);
begin
  nbCrud.Tag := ifthen(AOpen, 1, 0);
  if AOpen then
  begin
    btnAdd.Hide;
    btnEdit.Hide;
    btnRemove.Hide;
    btnSave.Show;
    btnCancel.Show;
  end
  else
  begin
    btnAdd.Show;
    btnEdit.Show;
    btnRemove.Show;
    btnSave.Hide;
    btnCancel.Hide;
  end;
end;

procedure TfrmClientes.GetRegister(AId: Integer);
var
  Clientes: TMapClientes;
  Cliente: TCliente;
begin
  if (AId > 0) then
  begin
    Clientes := TMapClientes.Create(con, 'clientes');
    Cliente := TCliente.Create;
    try
      Cliente.Id := AId;
      if Clientes.Get(Cliente) then
      begin
        lbCod.Caption           := Cliente.Id.to_s;
        lbDataCadastro.Caption  := Cliente.Data_cad.to_s;
        deAniversario.Date      := Cliente.Aniversario;
        edCpf.Text              := Cliente.Cpf_cnpj.maskCpfCnpj;
        edRg.Text               := Cliente.Rg_ie;
        edNome.Text             := Cliente.Nome;
        edTel1.Text             := Cliente.Telefone_1.maskPhone;
        edTel2.Text             := Cliente.Telefone_2.maskPhone;
        edCel1.Text             := Cliente.Celular_1.maskPhone;
        edCel2.Text             := Cliente.Celular_2.maskPhone;
        edEndereco.Text         := Cliente.Endereco;
        edBairro.Text           := Cliente.Bairro;
        edCep.Text              := Cliente.Cep.maskCep;
        edCidade.Text           := Cliente.Cidade;
        edUF.Text               := Cliente.Uf;
        edEmail.Text            := Cliente.Email;
        mmObs.Text              := Cliente.Observacao;
      end;
    finally
      Cliente.Free;
      Clientes.Free;
    end;
    setControls;
  end
    else clearFields;
end;

procedure TfrmClientes.AddRegister;
begin
  if nbCrud.Tag = 1 then Exit;
  if not pgDetails.Showing then
  begin
    pgDetails.Tag := 0;
    pgDetails.Show;
    setControls(True);
    deAniversario.SetFocus;
  end;
end;

procedure TfrmClientes.EditRegister;
begin
  if (nbCrud.Tag = 1) and (not pgDetails.Showing) then Exit;
  setControls(True);
  deAniversario.SetFocus;
end;

procedure TfrmClientes.RemoveRegister;
var
  Cliente: TCliente;
  Clientes: TMapClientes;
begin
  if (nbCrud.Tag = 1) or (pgDetails.Tag = 0) then Exit;
  if MessageDlg('Tem certeza que deseja excluir esse cliente?', mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then
  begin
    Cliente := TCliente.Create;
    Clientes :=TMapClientes.Create(con, 'clientes');
    try
      Cliente.Id := pgDetails.Tag;
      Clientes.Remove(Cliente);
      Clientes.Apply;
    finally
      Cliente.Free;
      Clientes.Free;
    end;
    GoBackToGrid;
    Flash('Cliente removido com sucesso!');
  end;
end;

procedure TfrmClientes.SaveRegister;
var
  Cliente: TCliente;
  Clientes: TMapClientes;
begin
  if (nbCrud.Tag= 0) then Exit;
  {=== Faz as validações ===}
  if not Validates then Exit;
  Cliente := TCliente.Create;
  Clientes := TMapClientes.Create(u_models.con, 'clientes');
  try
    Cliente.Aniversario := deAniversario.Date;
    Cliente.Cpf_cnpj    := edCpf.Text.raw_numbers;
    Cliente.Rg_ie       := edRg.Text.raw_numbers;
    Cliente.Nome        := edNome.Text.raw;
    Cliente.Telefone_1  := edTel1.Text.raw_numbers;
    Cliente.Telefone_2  := edTel2.Text.raw_numbers;
    Cliente.Celular_1   := edCel1.Text.raw_numbers;
    Cliente.Celular_2   := edCel2.Text.raw_numbers;
    Cliente.Endereco    := edEndereco.Text.raw;
    Cliente.Bairro      := edBairro.Text.raw;
    Cliente.Cep         := edCep.Text.raw_numbers;
    Cliente.Cidade      := edCidade.Text.raw;
    Cliente.Uf          := edUF.Text.raw;
    Cliente.Email       := edEmail.Text;
    Cliente.Observacao  := mmObs.Text.raw;
    Clientes.Nulls      := True;
    Cliente.Tipo        := IfThen((length(edCpf.Text.raw_numbers)>13), 'J', 'F');
    Clientes.Table.IgnoredFields.Add('data_cad');
    if (pgDetails.Tag > 0) then
    begin
      Cliente.Id := pgDetails.Tag;
      Clientes.Modify(Cliente);
    end
    else
      Clientes.Add(Cliente);
    Clientes.Apply;
  finally
    Cliente.Free;
    Clientes.Free;
  end;
  Flash(IfThen((pgDetails.Tag>0), 'Cliente modificado com sucesso', 'Cliente cadastrado com sucesso!'));
  GoBackToGrid;
end;

procedure TfrmClientes.CancelRegister;
begin
  if pgGrid.Showing then
    Close
  else
  begin
    GoBackToGrid;
    Flash('Operação cancelada.', kdNotify);
  end;
end;

procedure TfrmClientes.SetSearch;
begin
  if pgGrid.Showing then edSearch.SetFocus;
end;

procedure TfrmClientes.Flash(AMessage: String; AkdMsg: TKindMsg);
begin
  case AkdMsg of
    kdSucess: begin
      pnMsg.Color      := $00E6F5D2;
      pnMsg.Font.Color := $00489217;
    end;
    kdNotify: begin
      pnMsg.Color      := $00FFE0D0;
      pnMsg.Font.Color := $00DD842E;
    end;
    kdAlert: begin
      pnMsg.Color      := $00DFF8FF;
      pnMsg.Font.Color := $0000A8FF;
    end;
    kdError: begin
      pnMsg.Color      := $00EFF2FF;
      pnMsg.Font.Color := $000000F7;
      Beep;
    end;
  end;
  pnMsg.Caption := AMessage;
  pnMsg.Show;
  Timer.Enabled := True;
end;

function TfrmClientes.Validates: Boolean;
begin
  Result := False;
  if (Trim(edNome.Text) = '') then
    Flash('O campo "Nome" não pode ficar em branco.', kdError)
  else
    Result := True;
  if not Result then edNome.SetFocus;
end;

end.

