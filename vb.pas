unit UnitHy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,Math, ExtCtrls, TeeProcs, TeEngine, Chart, ComCtrls, StdCtrls,
  Buttons,StrUtils, TeeComma, TeeTools, Series, Grids, Spin;

type
  TFrmhy = class(TForm)
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts3: TTabSheet;
    ts4: TTabSheet;
    cht1: TChart;
    pnl1: TPanel;
    spl1: TSplitter;
    lbl1: TLabel;
    edtT: TEdit;
    lbl2: TLabel;
    lbl3: TLabel;
    edtP: TEdit;
    lbl4: TLabel;
    btnclose: TBitBtn;
    grp1: TGroupBox;
    grp2: TGroupBox;
    lbl5: TLabel;
    lbl6: TLabel;
    edtPr1: TEdit;
    lbl7: TLabel;
    lbl8: TLabel;
    edtT1: TEdit;
    edtPr2: TEdit;
    edtt2: TEdit;
    lbl9: TLabel;
    edtRg: TEdit;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    lbl13: TLabel;
    lbl14: TLabel;
    mmo1: TMemo;
    tcmndr1: TTeeCommander;
    grp3: TGroupBox;
    strngrd1: TStringGrid;
    cbb1: TComboBox;
    btnjia: TBitBtn;
    btnjian: TBitBtn;
    edt1: TEdit;
    lbl15: TLabel;
    edtPVT_T: TEdit;
    lbl16: TLabel;
    edtPVT_P: TEdit;
    rb1: TRadioButton;
    rb2: TRadioButton;
    lbl17: TLabel;
    lbl18: TLabel;
    btnOK: TBitBtn;
    procedure edtTKeyPress(Sender: TObject; var Key: Char);

    procedure edtPKeyPress(Sender: TObject; var Key: Char);
    procedure btnsumClick(Sender: TObject);
    procedure edtRgKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure strngrd1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure cbb1Change(Sender: TObject);
    procedure edt1Exit(Sender: TObject);
    procedure btnjiaClick(Sender: TObject);
    procedure btnjianClick(Sender: TObject);
    procedure edt1Change(Sender: TObject);
    procedure rb1Click(Sender: TObject);
    procedure rb2Click(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure cht1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    Function FunGetPRMF_T_To_P(T,Rg:Double):Double; //水合物生成 临界压力计算
    Function FunGetDXS_T_TO_P(T,Rg:Double):Double;
    Function FunGetPRMF_P_To_T(P,Rg:Double):Double;
    Function FunGetDXS_P_TO_T(P,Rg:Double):Double;

    Function FunGetK_F(Rg:Double ):string;
    Function FunGetRg():Double;
    procedure initDraw();
  public
    { Public declarations }
  end;

var
  Frmhy: TFrmhy;

implementation
   uses PubUnit,CusData;
{$R *.dfm}


Function TFrmhy.FunGetRg():Double;
var
   iRow:integer;
   dbrg,dbSum:double;
begin
   iRow := 1;
   dbSum :=0;
   while self.strngrd1.Cells[1,irow]<>'' do begin
      dbSum:=dbSum + StrToFloat(self.strngrd1.Cells[2,irow]);
      irow:=irow+1;
   end;
   if CompareValue(dbSum,100) <> 0 then begin
       dbrg :=0;
   end else begin
        dbrg :=1;
   end;
   result:=dbrg;
end;

  //      波诺马列夫法
// 二次多项式 相对密度  返回 K  P;
Function TFrmhy.FunGetK_F(Rg:Double):string;
var
    k,f:double;
begin
   k:=0;
   f:=0;
   if (CompareValue(Rg ,0.56)>=0) and (CompareValue(Rg ,0.6)<0) then begin
      k:=0.014;
      f:=1.12;
   end;
   if (CompareValue(Rg ,0.6)>=0) and (CompareValue(Rg ,0.7)<0) then begin
       k:=0.005;
      f:=1.00;
   end;
  if (CompareValue(Rg ,0.7)>=0) and (CompareValue(Rg ,0.8)<0) then begin
      k:=0.0075;
      f:=0.82;
   end;
  if (CompareValue(Rg ,0.8)>=0) and (CompareValue(Rg ,0.9)<0) then begin
      k:=0.01;
      f:=0.7;
   end;
   if (CompareValue(Rg ,0.9)>=0) and (CompareValue(Rg ,1)<0) then begin
      k:=0.0127;
      f:=0.61;
   end;
    if (CompareValue(Rg ,1.0)>=0) and (CompareValue(Rg ,1.1)<0) then begin
      k:=0.017;
      f:=0.54;
   end;
   if (CompareValue(Rg ,1.1)>= 0) then begin
      k:=0.02;
      f:=0.46;
   end;
   Result:=FloatToStr(k) + '_' + FloatToStr(f) ;



end;


procedure TFrmhy.edtTKeyPress(Sender: TObject; var Key: Char);
begin
  if Not (key in ['0'..'9',#8,'.',#13,#3,#22]) then
  begin
    Application.MessageBox('只能输入数字！','提示',64);
    Key := #0;
    self.edtT.SetFocus;
  end;
end;



procedure TFrmhy.edtPKeyPress(Sender: TObject; var Key: Char);
begin
     if Not (key in ['0'..'9',#8,'.',#13,#3,#22]) then
  begin
    Application.MessageBox('只能输入数字！','提示',64);
    Key := #0;
    self.edtP.SetFocus;
  end;
end;

procedure TFrmhy.btnsumClick(Sender: TObject);
var
  T,P,dbRg,Pr,dbPr,Tr,dbTr:Double;
begin
  dbTr:=0;
  if (self.edtRg.text='') or (self.edtRg.Text ='0') then begin
    Application.MessageBox('天然气相对密度必填，不能为空！','提示',64);
    Exit;
  end;
  dbRg:=RoundTo(strtofloat(self.edtRg.Text)+0.001,-2);

  //检查是组份含量
  if self.pgc1.ActivePageIndex =2 then begin
     dbRg:= FunGetRg();    //组份含量计算相对密度
     if (dbRg =0) then begin
        Application.MessageBox('组份体积含量不足100%！','提示',64);
        Exit;
     end;
  end;


  if self.rb1.Checked  then begin
      if (self.edtT.Text ='')  then begin
        Application.MessageBox('温度不能同时为空！','提示',64);
        Exit;
      end;
      T:=StrToFloat(self.edtT.Text)+273;   //  摄氏度  转化为   K
      pr:=RoundTo(Self.FunGetPRMF_T_To_P(t,dbRg),-4) ;
      if (CompareValue(dbRg,0.6)>=0) and (dbRg<1.1) then  begin
         dbPr:=FunGetDXS_T_TO_P(t,dbRg);
      end else begin
         dbPr:=0;
      end;

      if self.pgc1.ActivePageIndex =1 then begin
         self.edtPr1.Text :=FloatToStr(pr);
         Self.edtPr2.Text :=FloatToStr(dbPr);
      end;
      if self.pgc1.ActivePageIndex =2 then
         self.edtPVT_P.Text :=FloatToStr(pr*1.01);
  end;
  if self.rb2.Checked then begin
      if (self.edtP.Text ='')  then begin
         Application.MessageBox('压力不能同时为空！','提示',64);
         Exit;
      end;
      P:=StrToFloat(self.edtP.Text);
      Tr:= FunGetPRMF_P_To_T(P,dbRg);

      if (CompareValue(dbRg,0.6)>=0) and (dbRg<1.1) and (p<30) then  begin
          dbTr:=self.FunGetDXS_P_TO_T(p,dbRg);
      end else begin

      end;
      if self.pgc1.ActivePageIndex =1 then begin
         self.edtT1.Text :=FloatToStr(Tr-273);
         self.edtT2.Text :=FloatToStr(dbTr-273);
      end;
      if self.pgc1.ActivePageIndex =2 then
         self.edtPVT_T.Text:= FloatToStr(Tr-273);
   end;

  // if (CompareValue(P,0)>0) then begin
end;

Function TFrmhy.FunGetPRMF_T_To_P(T,Rg:Double):Double;//水合物生成 临界压力计算
var
  I: Integer;
  B,P:double;
  X, Y:array of double;
begin
  initRgBB1;
  setlength(x,5);setlength(y,5);
  for I := 0 to high(arrRg) do begin    // Iterate
    if arrRg[i]>=Rg then begin
      if i<=1 then begin
        X[0]:=arrRg[i];X[1]:=arrRg[i+1];X[2]:= arrRg[i+2];X[3]:=arrRg[i+3];X[4]:= arrRg[i+4];
        if T>=273.1 then begin
          Y[0]:=arrB[i];Y[1]:=arrB[i+1];Y[2]:= arrB[i+2];Y[3]:=arrB[i+3];Y[4]:= arrB[i+4];
        end else begin
          Y[0]:=arrB1[i];Y[1]:=arrB1[i+1];Y[2]:= arrB1[i+2];Y[3]:=arrB1[i+3];Y[4]:= arrB1[i+4];
        end;
      end;
      if (i>=2) and (i<=high(arrRg)-2) then begin
        X[0]:=arrRg[i-2];X[1]:=arrRg[i-1];X[2]:= arrRg[i];X[3]:=arrRg[i+1];X[4]:= arrRg[i+2];
        if T>=273.1 then begin
          Y[0]:=arrB[i-2];Y[1]:=arrB[i-1];Y[2]:= arrB[i];Y[3]:=arrB[i+1];Y[4]:= arrB[i+2];
        end else begin
          Y[0]:=arrB1[i-2];Y[1]:=arrB1[i-1];Y[2]:= arrB1[i];Y[3]:=arrB1[i+1];Y[4]:= arrB1[i+2];
        end;
      end;
      if i>=high(arrRg)-2 then begin
        X[0]:=arrRg[i-3];X[1]:=arrRg[i-2];X[2]:= arrRg[i-1];X[3]:=arrRg[i];X[4]:= arrRg[i+1];
        if T>=273.1 then begin
          Y[0]:=arrB[i-3];Y[1]:=arrB[i-2];Y[2]:= arrB[i-1];Y[3]:=arrB[i];Y[4]:= arrB[i+1];
        end  else begin
          Y[0]:=arrB1[i-3];Y[1]:=arrB1[i-2];Y[2]:= arrB1[i-1];Y[3]:=arrB1[i];Y[4]:= arrB1[i+1];
        end;
      end;
      break;
    end;
  end;    // for
  B:=NewtonCZ(X,Y,5,Rg);
   if T>=273.1 then
     P:=power(10,-1.0055+0.0541*(B+T-273.1))
   else
     P:=power(10,-1.0055+0.0171*(B+T-273.1));
  result:=RoundTo(p,-4);
end;

Function TFrmhy.FunGetPRMF_P_To_T(P,Rg:Double):Double;
var
  I: Integer;
  B,T:double;
  X, Y:array of double;
begin
  initRgBB1;
  setlength(x,5);setlength(y,5);
  T:=273.1;
  for I := 0 to high(arrRg) do begin    // Iterate
    if arrRg[i]>=Rg then begin
      if i<=1 then begin
        X[0]:=arrRg[i];X[1]:=arrRg[i+1];X[2]:= arrRg[i+2];X[3]:=arrRg[i+3];X[4]:= arrRg[i+4];
        if T>=273.1 then begin
          Y[0]:=arrB[i];Y[1]:=arrB[i+1];Y[2]:= arrB[i+2];Y[3]:=arrB[i+3];Y[4]:= arrB[i+4];
        end else begin
          Y[0]:=arrB1[i];Y[1]:=arrB1[i+1];Y[2]:= arrB1[i+2];Y[3]:=arrB1[i+3];Y[4]:= arrB1[i+4];
        end;
      end;
      if (i>=2) and (i<=high(arrRg)-2) then begin
        X[0]:=arrRg[i-2];X[1]:=arrRg[i-1];X[2]:= arrRg[i];X[3]:=arrRg[i+1];X[4]:= arrRg[i+2];
        if T>=273.1 then begin
          Y[0]:=arrB[i-2];Y[1]:=arrB[i-1];Y[2]:= arrB[i];Y[3]:=arrB[i+1];Y[4]:= arrB[i+2];
        end else begin
          Y[0]:=arrB1[i-2];Y[1]:=arrB1[i-1];Y[2]:= arrB1[i];Y[3]:=arrB1[i+1];Y[4]:= arrB1[i+2];
        end;
      end;
      if i>=high(arrRg)-2 then begin
        X[0]:=arrRg[i-3];X[1]:=arrRg[i-2];X[2]:= arrRg[i-1];X[3]:=arrRg[i];X[4]:= arrRg[i+1];
        if T>=273.1 then begin
          Y[0]:=arrB[i-3];Y[1]:=arrB[i-2];Y[2]:= arrB[i-1];Y[3]:=arrB[i];Y[4]:= arrB[i+1];
        end  else begin
          Y[0]:=arrB1[i-3];Y[1]:=arrB1[i-2];Y[2]:= arrB1[i-1];Y[3]:=arrB1[i];Y[4]:= arrB1[i+1];
        end;
      end;
      break;
    end;
  end;    // for
  B:=NewtonCZ(X,Y,5,Rg);
  if T>=273.1 then
    T:=(log10(P)+1.0055)/0.0541-B
  else
    T:=(log10(P)+1.0055)/0.0171-B;
  result:=roundto(T,-4);

end;
  //二次多项式法

Function TFrmhy.FunGetDXS_T_TO_P(T,Rg:Double):Double;
var
  p:Double;
  k,f:double;
  str:string;
begin
  str:=self.FunGetK_F(Rg);
  p:=0;
  try
    k:=StrToFloat(LeftStr(str,Pos('_',str)-1));
    f:=StrToFloat(RightStr(str,length(str)-Pos('_',str)));
    p:=((t-273)+k*POWER(t-273,2))+f;
   // p:=Power(10,p) ;

  except

  end;
  result:=p;
end;

Function TFrmhy.FunGetDXS_P_TO_T(P,Rg:Double):Double;
var
  k,f,db,dbT1,dbT2,dbt:double;
  str:string;
begin
  str:=self.FunGetK_F(Rg);
  dbt:=0;
  try
    k:=StrToFloat(LeftStr(str,Pos('_',str)-1));
    f:=StrToFloat(RightStr(str,length(str)-Pos('_',str)));
    db:=1-4*k*(f-p);
    if db>0 then begin
       dbT1:=(power(db,0.5)-1)/(2*k);
       dbT2:=(-power(db,0.5)-1)/(2*k);
       If dbT1>dbT2 then
          dbt:=dbt1
       else
          dbt:=dbt2;
    end else begin
       dbt:=0;
    end;
  except

  end ;
  result:=RoundTo(dbt,-4);
end;

procedure TFrmhy.edtRgKeyPress(Sender: TObject; var Key: Char);
begin
  if Not (key in ['0'..'9',#8,'.',#13,#3,#22]) then
  begin
    Application.MessageBox('只能输入数字！','提示',64);
    Key := #0;
    self.edtRg.SetFocus;
  end;
end;


procedure TFrmhy.initDraw();
var
   sql:string;
   strLineList:tstringlist;
   i:Integer;
   x,y:Double;
   pSeries:TLineSeries;
begin
   strLineList:=tstringlist.Create;
   sql:='select distinct seriesname from t_hy';
   CustomerData.GetAdoQuery(sql);
   while not CustomerData.ADOQuery1.Eof do begin
     strLineList.Add(CustomerData.ADOQuery1.FieldValues['seriesname']) ;
     CustomerData.ADOQuery1.Next;
   end;
   sql:='select *  from t_hy order by iid' ;
   CustomerData.GetAdoQuery(sql);
   for i:=0 to strLineList.Count -1 do begin
      CustomerData.ADOQuery1.Filter:='seriesname=''' + strLineList[i] + '''';
      customerdata.ADOQuery1.Filtered :=true;
      customerdata.ADOQuery1.First;
      pSeries:=TLineSeries.Create(self);
      pSeries.Pen.Width :=3;
      if Pos('V', strLineList[i])<=0 then begin
         pSeries.Color:=RGB(0,0,0);
         pSeries.Pen.Color:= RGB(0,0,0);
         pSeries.SeriesColor:=RGB(0,0,0);
          pSeries.Pen.Width :=1;
      end;
      pSeries.Title:=strLineList[i];
      while not customerdata.ADOQuery1.Eof  do begin

        if customerdata.ADOQuery1.Fields.FieldByName('x').IsNull    then
          X:=0
        else
          X:=customerdata.ADOQuery1.FieldValues['X'];
        if customerdata.ADOQuery1.Fields.FieldByName('Y').IsNull    then
          y:=0
        else
          y:=customerdata.ADOQuery1.FieldValues['Y'];
        pSeries.AddXY(x,y,strLineList[i])  ;
        customerdata.ADOQuery1.Next;
      end;    // while
      customerdata.ADOQuery1.Filtered :=false;
      self.cht1.AddSeries(pSeries);
    end;    // for
    customerdata.ADOQuery1.Filtered:=false;
    CustomerData.ADOQuery1.Close;





    strLineList.Free;

end;

procedure TFrmhy.FormShow(Sender: TObject);
begin
   initDraw;
   Self.strngrd1.Cells[0,0]:='序号';
   self.strngrd1.Cells[1,0]:='组分';
   self.strngrd1.Cells[2,0]:='百分比%';
end;

procedure TFrmhy.strngrd1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
   if self.strngrd1.Focused   then begin
      if (ACol = 1) or ( ACol = 3) then begin
          Self.cbb1.SetBounds(rect.Left+strngrd1.Left+1,rect.Top+strngrd1.Top+1,rect.Right-rect.Left+2,rect.Bottom-rect.Top+2);//绑定单元格，本来可以不加2的，总是发现 ComboBox 的 size 要比单元格小，所以干脆膨胀好了
          Self.cbb1.Visible:=true;
          Self.cbb1.SetFocus;
          self.edt1.Visible :=false;
      end else begin
          self.edt1.SetBounds(rect.Left+strngrd1.Left+1,rect.Top+strngrd1.Top+1,rect.Right-rect.Left+2,rect.Bottom-rect.Top+2);//绑定单元格，本来可以不加2的，总是发现 ComboBox 的 size 要比单元格小，所以干脆膨胀好了
          self.edt1.Visible:=true;
          self.edt1.SetFocus;
          self.cbb1.Visible :=false;
      end;
   end;
  with Sender as TStringGrid do
  begin
      Canvas.FillRect(Rect);
      DrawText(Canvas.Handle, PChar(Cells[ACol, ARow]), Length(Cells[ACol, ARow]), Rect, DT_CENTER or DT_SINGLELINE or DT_VCENTER);
  end;
end;
///
procedure TFrmhy.cbb1Change(Sender: TObject);
begin
   self.strngrd1.Cells[strngrd1.Col,strngrd1.Row]:=Trim(cbb1.Text);
   if (self.strngrd1.Cells[strngrd1.Col,strngrd1.Row]<>'') then begin
      self.strngrd1.Cells[0,strngrd1.Row] :=IntToStr(self.strngrd1.Row);
   end;

end;

procedure TFrmhy.edt1Exit(Sender: TObject);
begin
    self.strngrd1.Cells[strngrd1.Col,strngrd1.Row]:=Trim(edt1.Text);
end;

procedure TFrmhy.btnjiaClick(Sender: TObject);
begin
   self.strngrd1.RowCount :=self.strngrd1.RowCount +1; 
end;

procedure TFrmhy.btnjianClick(Sender: TObject);
begin
   if Self.strngrd1.RowCount >2 then
    self.strngrd1.RowCount :=self.strngrd1.RowCount -1;
end;

procedure TFrmhy.edt1Change(Sender: TObject);
begin
  if not isNumber(self.edt1.Text)  then
  begin
    application.MessageBox('输入格式错误，请重新输入！','提示',64) ;
    self.edt1.Text:='';
    self.edt1.SetFocus;
  end;
end;

procedure TFrmhy.rb1Click(Sender: TObject);
begin
  if self.rb1.Checked then begin
    self.edtT.Enabled :=true;
    self.edtP.Enabled :=False;
    self.edtT.Ctl3D :=true;
    self.edtP.Ctl3D :=false;
  end else begin
    self.edtT.Enabled :=false;
    self.edtP.Enabled :=true;
    self.edtT.Ctl3D :=false;
    self.edtP.Ctl3D :=true;
  end;

end;

procedure TFrmhy.rb2Click(Sender: TObject);
begin
  if self.rb1.Checked then begin
    self.edtT.Enabled :=true;
    self.edtP.Enabled :=False;
    self.edtT.Ctl3D :=true;
    self.edtP.Ctl3D :=false;
  end else begin
    self.edtT.Enabled :=false;
    self.edtP.Enabled :=true;
    self.edtT.Ctl3D :=false;
    self.edtP.Ctl3D :=true;
  end;
end;

procedure TFrmhy.btnOKClick(Sender: TObject);
var
  T,P,dbRg,Pr,dbPr,Tr,dbTr:Double;
begin
  dbTr:=0;
  if (self.edtRg.text='') or (self.edtRg.Text ='0') then begin
    Application.MessageBox('天然气相对密度必填，不能为空！','提示',64);
    Exit;
  end;
  dbRg:=RoundTo(strtofloat(self.edtRg.Text)+0.001,-2);

  //检查是组份含量
  if self.pgc1.ActivePageIndex =2 then begin
     dbRg:= FunGetRg();    //组份含量计算相对密度
     if (dbRg =0) then begin
        Application.MessageBox('组份体积含量不足100%！','提示',64);
        Exit;
     end;
  end;


  if self.rb1.Checked  then begin
      if (self.edtT.Text ='')  then begin
        Application.MessageBox('温度不能同时为空！','提示',64);
        Exit;
      end;
      T:=StrToFloat(self.edtT.Text)+273;   //  摄氏度  转化为   K
      pr:=RoundTo(Self.FunGetPRMF_T_To_P(t,dbRg),-4) ;
      if (CompareValue(dbRg,0.6)>=0) and (dbRg<1.1) then  begin
         dbPr:=FunGetDXS_T_TO_P(t,dbRg);
      end else begin
         dbPr:=0;
      end;

      if self.pgc1.ActivePageIndex =0 then begin
         self.edtPr1.Text :=FloatToStr(pr);
         Self.edtPr2.Text :=FloatToStr(dbPr);
      end;
      if self.pgc1.ActivePageIndex =1 then
         self.edtPVT_P.Text :=FloatToStr(pr*1.01);
  end;
  if self.rb2.Checked then begin
      if (self.edtP.Text ='')  then begin
         Application.MessageBox('压力不能同时为空！','提示',64);
         Exit;
      end;
      P:=StrToFloat(self.edtP.Text);
      Tr:= FunGetPRMF_P_To_T(P,dbRg);

      if (CompareValue(dbRg,0.6)>=0) and (dbRg<1.1) and (p<30) then  begin
          dbTr:=self.FunGetDXS_P_TO_T(p,dbRg);
      end else begin

      end;
      if self.pgc1.ActivePageIndex =0 then begin
         self.edtT1.Text :=FloatToStr(Tr-273);
         self.edtT2.Text :=FloatToStr(dbTr-273);
      end;
      if self.pgc1.ActivePageIndex =1 then
         self.edtPVT_T.Text:= FloatToStr(Tr-273);
   end;

end;

procedure TFrmhy.cht1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
    cht1.Repaint;
    if (x<33) or (x>559) then exit;
     if (y<68) or (y>590) then exit;
      With cht1,Canvas do
      begin
        Pen.Color:=clYellow;
        Pen.Style:=psSolid;
        Pen.Mode:=pmXor;
        Pen.Width:=1;
        MoveTo(x,ChartRect.Top-Height3D);
        LineTo(x,ChartRect.Bottom-Height3D);
        MoveTo(ChartRect.Left+Width3D,y);
        LineTo(ChartRect.Right+Width3D,y);
      end;
end;

end.
