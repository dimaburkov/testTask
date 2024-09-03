unit EditQty;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TFEditQty = class(TForm)
    Panel1: TPanel;
    BitBtnExit: TBitBtn;
    BitBtnSave: TBitBtn;
    Label2: TLabel;
    Label1: TLabel;
    EditProductName: TEdit;
    EditQty: TEdit;
    procedure BitBtnExitClick(Sender: TObject);
    procedure BitBtnSaveClick(Sender: TObject);
    procedure EditQtyChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor CreateID(AOwner: TComponent; quantity : Double; product_name : String);
    function GetQty():Double;
  end;

var
  FEditQty: TFEditQty;
  order_details_ID : integer;
  qty : double;
implementation

{$R *.dfm}

function TFEditQty.GetQty():Double;
begin
   result:=qty;
   //Close();
end;

constructor TFEditQty.CreateID(AOwner : TComponent; quantity : Double; product_name : String);
begin
   inherited Create(Owner);
   qty := quantity;
   EditQty.Text := FloatToStr(quantity);
   EditProductName.Text := product_name;
end;

procedure TFEditQty.EditQtyChange(Sender: TObject);
begin
  BitBtnSave.Enabled:= true;
end;

procedure TFEditQty.BitBtnExitClick(Sender: TObject);
begin
   if BitBtnSave.Enabled=true then
      if Application.MessageBox('Changes not saved. Continue?','Attention!',MB_OKCANCEL+MB_ICONWARNING)= mrCancel then
         Exit;
   Close();
end;

procedure TFEditQty.BitBtnSaveClick(Sender: TObject);
begin
   qty := StrToFloat(EditQty.Text);
   ModalResult:=1;
end;

end.
