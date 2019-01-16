(*
  MGeoIP plugin.
  Copyright (C) 2012-2014 Silvio Clecio.

  Please see the LICENSE file.
*)

unit MGeoIP;

{$mode objfpc}{$H+}

interface

uses
  GeoIP, HttpSend, Classes, SysUtils;

type
  TDBInfo = (dbiCountry, dbiCity);

{ Lookup information from the MaxMind database. }
function LookupDBInfo(const ADBInfo: TDBInfo = dbiCountry): string;
{ Lookup country. (Code and name) }
function LookupCountry(const AIP: ShortString): TGeoIPCountry;
{ Lookup city. (code, country name, region, city, postal code, latitude,
  longitude, Dma code and  areaCode). }
function LookupCity(const AIP: ShortString): TGeoIPCity;
{ Lookup map via Google Maps API. }
function LookupGoogleMaps(AImage: TStream; const ALatitude,
  ALongitude: Double; const AGoogleMapsAPIKey: string = '';
  const AImageWidthSize: Integer = 390; const AImageHeightSize: Integer = 175;
  const AImageZoom: Byte = 8): Boolean;

const
  GOOGLEMAPS_API_URL =
    'http://maps.google.com/staticmap?key=%s&size=%dx%d&markers=%f,%f&zoom=%d';
var
  COUNTRY_DAT_FILENAME: TFileName = 'GeoIP.dat';
  CITY_DAT_FILENAME: TFileName = 'GeoLiteCity.dat';

implementation

function LookupDBInfo(const ADBInfo: TDBInfo): string;
var
  VGeoIP: TGeoIP;
begin
  case ADBInfo of
    dbiCountry: VGeoIP := TGeoIP.Create(COUNTRY_DAT_FILENAME);
    dbiCity: VGeoIP := TGeoIP.Create(CITY_DAT_FILENAME);
  end;
  try
    Result := VGeoIP.GetDatabaseInfo;
  finally
    VGeoIP.Free;
  end;
end;

function LookupCountry(const AIP: ShortString): TGeoIPCountry;
var
  VGeoIP: TGeoIP;
begin
  VGeoIP := TGeoIP.Create(COUNTRY_DAT_FILENAME);
  try
    if not (VGeoIP.GetCountry(AIP, Result) = GEOIP_SUCCESS) then
      with Result do
      begin
        CountryCode := '';
        CountryName := '';
      end;
  finally
    VGeoIP.Free;
  end;
end;

function LookupCity(const AIP: ShortString): TGeoIPCity;
var
  VGeoIP: TGeoIP;
begin
  VGeoIP := TGeoIP.Create(CITY_DAT_FILENAME);
  try
    if not (VGeoIP.GetCity(AIP, Result) = GEOIP_SUCCESS) then
      with Result do
      begin
        CountryCode := '';
        CountryName := '';
        Region := '';
        City := '';
        PostalCode := '';
        Latitude := 0;
        Longitude := 0;
        DmaCode := 0;
        AreaCode := 0;
      end;
  finally
    VGeoIP.Free;
  end;
end;

function LookupGoogleMaps(AImage: TStream; const ALatitude,
  ALongitude: Double; const AGoogleMapsAPIKey: string;
  const AImageWidthSize, AImageHeightSize: Integer;
  const AImageZoom: Byte): Boolean;
var
  VHttp: THttpSend;
  VOldDecSep: Char;
begin
  VOldDecSep := DefaultFormatSettings.DecimalSeparator;
  DefaultFormatSettings.DecimalSeparator := '.';
  VHttp := THttpSend.Create;
  try
    Result := HttpGetBinary(Format(GOOGLEMAPS_API_URL,
      [AGoogleMapsAPIKey, AImageWidthSize, AImageHeightSize, ALongitude,
      ALatitude, AImageZoom]), AImage);
    if Result then
      AImage.Position := 0;
  finally
    VHttp.Free;
    DefaultFormatSettings.DecimalSeparator := VOldDecSep;
  end;
end;

end.

