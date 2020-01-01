unit Numedit;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls;

type
  TNumEdit = class(TEdit)
  protected
    function AsInt : longint;
    procedure SetInt(i : longint);
  published
    property Number : longint read AsInt write SetInt;
    { Published declarations }
  end;



implementation

function TNumEdit.AsInt : longint;
begin
  try
    Result:=StrToInt(Text);
  except
    on EConvertError do
      Result:=0;
  end;
end;

procedure TNumEdit.SetInt(i : longint);
begin
  Text:=IntToStr(i);
end;

end.
