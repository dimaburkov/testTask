unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WideStrings, DBXMsSQL, FMTBcd, StdCtrls, DB, SqlExpr, Grids, EditQty,
  Buttons, ExtCtrls;

type Products = ^AList;
  AList = record
     id : Integer;
     name, barcode : String;
     qty, amount : Double;
  end;
type
  TForm1 = class(TForm)
    SQLConnection1: TSQLConnection;
    SQLQuery1: TSQLQuery;
    Button1: TButton;
    EdBarcode: TEdit;
    DrawGridRashodRows: TDrawGrid;
    Label1: TLabel;
    Button2: TButton;
    Edit2: TEdit;
    Label2: TLabel;
    Panel1: TPanel;
    BitBtnExit: TBitBtn;
    BitBtnSave: TBitBtn;
    procedure Button1Click(Sender: TObject);
    procedure DrawGridRashodRowsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BitBtnSaveClick(Sender: TObject);
    procedure BitBtnExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  list_products : TList;
  order_id : integer;

implementation

{$R *.dfm}

var
  i: Integer;
  sum : double;
  t: Products;

procedure TForm1.BitBtnExitClick(Sender: TObject);
begin
   Close();
end;

procedure TForm1.BitBtnSaveClick(Sender: TObject);
begin
   //save in db
   if (list_products.Count = 0) or (order_id = 0) then
     Exit;
   sum := 0;
   for i := 0 to list_products.Count - 1 do
   begin
     t := list_products.Items[i];
     sum := sum + t.amount*t.qty;
   end;

   SQLQuery1.Close();
   SQLQuery1.SQL.Clear();
   SQLQuery1.SQL.Add('Update orders set total='+FloatToStr(sum)+
   ' where order_id='+IntToStr(order_id));
   SQLQuery1.ExecSQL();

   //update qty in db
   for i := 0 to list_products.Count - 1 do
   begin
     t := list_products.Items[i];
     SQLQuery1.Close();
     SQLQuery1.SQL.Clear();
     SQLQuery1.SQL.Add('Update order_details set qty='+FloatToStr(t.qty)+
     ' where id='+IntToStr(t.id));
     SQLQuery1.ExecSQL();
   end;
   BitBtnSave.Enabled := false;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   i: Integer;
   t: Products;
begin
   if list_products.Count = 0 then
   begin
     ShowMessage('Order is empty!');
     Exit;
   end;
   if EdBarcode.Text = '' then
   begin
     ShowMessage('Barcode is empty!');
     Exit;
   end;
   for i := 0 to list_products.Count - 1 do
   begin
      t := list_products.Items[i];
      if t.barcode = EdBarcode.Text then
      begin
        FEditQty := TFEditQty.CreateID(Self, t.qty , t.name);
        FEditQty.ShowModal;
        if(FEditQty.ModalResult=1)  then
        begin
         t.qty := FEditQty.GetQty();
         list_products.Items[i] := t;
         BitBtnSave.Enabled := true;
         DrawGridRashodRows.Refresh();
       end;
       FEditQty.Free;
     end;

   end;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
   row : Products;
begin
   list_products := TList.Create;
   SQLQuery1.Close();
   SQLQuery1.SQL.Clear();
   SQLQuery1.SQL.Add('Select * from order_details od'+
   ' join products p on od.product_id = p.product_id '+
   ' where order_id='+Edit2.Text);

   SQLQuery1.Open();
   if SQLQuery1.RecordCount>0 then
     order_id := SQLQuery1.FieldByName('order_id').AsInteger;

   while SQLQuery1.Eof <> true do

   begin
     //found the order
     New(row);
     row.id := SQLQuery1.FieldByName('id').AsInteger;
     row.name := SQLQuery1.FieldByName('name').AsString;
     row.barcode := SQLQuery1.FieldByName('barcode').AsString;
     row.qty := SQLQuery1.FieldByName('qty').AsFloat;
     row.amount := SQLQuery1.FieldByName('price').AsFloat;
     list_products.Add(row);
     SQLQuery1.Next;

   end;

   SQLQuery1.Close();
   if list_products.Count > 0 then
   begin
     DrawGridRashodRows.RowCount := list_products.Count + 1;
   end
   else
     begin
     DrawGridRashodRows.RowCount := 2;
     ShowMessage('Order number '+Edit2.Text+' not found');
     end;
   DrawGridRashodRows.Refresh();
end;

procedure TForm1.DrawGridRashodRowsDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
   TheRect:TRect;
   x,y:Integer;
   rd : Products;
begin
   TheRect.Left := Rect.Left-1;
   TheRect.Top := Rect.Top-1;
   TheRect.Right := Rect.Right+1;
   TheRect.Bottom := Rect.Bottom+1;
   if ( ARow = 0) then begin
     case ACol of
      0 : begin DrawGridRashodRows.Canvas.TextOut(Rect.Left+(DrawGridRashodRows.ColWidths[0]-DrawGridRashodRows.Canvas.TextWidth('Product')) div 2,Rect.Top+2,'Product');
                  DrawGridRashodRows.Canvas.Brush.Color := clBlack;
                  DrawGridRashodRows.Canvas.FrameRect(TheRect);
          end;
      1 : begin DrawGridRashodRows.Canvas.TextOut(Rect.Left+(DrawGridRashodRows.ColWidths[1]-DrawGridRashodRows.Canvas.TextWidth('Barcode')) div 2,Rect.Top+2,'Barcode');
                  DrawGridRashodRows.Canvas.Brush.Color := clBlack;
                  DrawGridRashodRows.Canvas.FrameRect(TheRect);
          end;
      2 : begin DrawGridRashodRows.Canvas.TextOut(Rect.Left+(DrawGridRashodRows.ColWidths[2]-DrawGridRashodRows.Canvas.TextWidth('Quantity')) div 2,Rect.Top+2,'Quantity');
                  DrawGridRashodRows.Canvas.Brush.Color := clBlack;
                  DrawGridRashodRows.Canvas.FrameRect(TheRect);
          end;

      3 : begin DrawGridRashodRows.Canvas.TextOut(Rect.Left+(DrawGridRashodRows.ColWidths[3]-DrawGridRashodRows.Canvas.TextWidth('Amount')) div 2,Rect.Top+2,'Amount');
                  DrawGridRashodRows.Canvas.Brush.Color := clBlack;
                  DrawGridRashodRows.Canvas.FrameRect(TheRect);
          end;
     end;
   end
   else
   begin
      if list_products.Count = 0 then
         Exit;
      rd := list_products.Items[ARow-1];
      case ACol of
      0: begin    DrawGridRashodRows.Canvas.TextOut(Rect.Left+2,Rect.Top+4,rd.name);
                  DrawGridRashodRows.Canvas.Brush.Color := clBtnFace;
                  DrawGridRashodRows.Canvas.FrameRect(TheRect);
         end;

      1: begin    DrawGridRashodRows.Canvas.TextOut(Rect.Left+2,Rect.Top+4,rd.barcode);
                  DrawGridRashodRows.Canvas.Brush.Color := clBtnFace;
                  DrawGridRashodRows.Canvas.FrameRect(TheRect);
         end;

      2: begin    DrawGridRashodRows.Canvas.TextOut(Rect.Right-DrawGridRashodRows.Canvas.TextWidth(FloatToStrF(rd.qty, ffFixed, 18, 2))-5,Rect.Top+4,FloatToStrF(rd.qty, ffFixed, 18, 2));
                  DrawGridRashodRows.Canvas.Brush.Color := clBtnFace;
                  DrawGridRashodRows.Canvas.FrameRect(TheRect);
      end;

      3: begin    DrawGridRashodRows.Canvas.TextOut(Rect.Right-DrawGridRashodRows.Canvas.TextWidth(FloatToStrF(rd.amount, ffFixed, 18, 2))-5,Rect.Top+4,FloatToStrF(rd.amount, ffFixed, 18, 2));
                  DrawGridRashodRows.Canvas.Brush.Color := clBtnFace;
                  DrawGridRashodRows.Canvas.FrameRect(TheRect);

      end;
      end;

   end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
   list_products := TList.Create;
   order_id := 0;
end;

end.
