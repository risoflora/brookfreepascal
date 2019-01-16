unit Test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookConsts, GeoIP, MGeoIP, BrookRequestHelper, Classes, SysUtils;

type
  TTest = class(TBrookAction)
  public
    procedure Request(ARequest: TBrookRequest;
      AResponse: TBrookResponse); override;
  end;

implementation

procedure TTest.Request(ARequest: TBrookRequest; AResponse: TBrookResponse);
var
  VCity: TGeoIPCity;
  VAddr: ShortString;
  VImgFileName: TFileName;
  VImgStream: TMemoryStream;
begin
  VAddr := ARequest.RemoteAddr;
  if (VAddr = ES) or (VAddr = '127.0.0.1') then
    VAddr := '64.90.180.0'; // Dummy IP
  VCity := LookupCity(VAddr);
  WriteLn('%s - %s', [VCity.CountryName, VCity.City]);
  if VCity.CountryCode <> '' then
  begin
    VImgStream := TMemoryStream.Create;
    try
      if LookupGoogleMaps(VImgStream, VCity.Longitude, VCity.Latitude) then
      begin
        VImgFileName := ARequest.GetDocumentRoot + 'maps.png';
        VImgStream.SaveToFile(VImgFileName);
        WriteLn('<img src="/maps.png" />');
      end;
    finally
      VImgStream.Free;
    end;
  end;
end;

initialization
  TTest.Register('*');

end.
