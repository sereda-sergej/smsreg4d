unit SmsReg4D;

interface

uses
  System.SysUtils,
  XSuperObject;

type
  ISmsRegHttpClient = interface
  ['{5E96F84D-D75E-471F-95A7-0E84F02D62A4}']
    function Get(url: string): string;
  end;

  ISmsRegClient = interface
  ['{E1350BE7-93CA-4850-933F-9CD1F38BB3E8}']
    function GetNumber(service: string = 'other'; country: string = ''): string;
    procedure SetReady(tzid: string);
  end;

  SmsReg = class sealed
  private type
    Responses = class
    type
      Base = class
        [Alias('response')]
        Status: string;

        [Alias('error_msg')]
        Error: string;
      end;

      GetNumber = class(Base)
        [Alias('tzid')]
        tzid: string;
      end;
    end;
  public type
    Services = class sealed
    const
      Aol        = 'aol';
      Gmail      = 'gmail';
      Facebook   = 'facebook';
      Mailru     = 'mailru';
      Vk         = 'vk';
      Classmates = 'classmates';
      Twitter    = 'twitter';
      Mamba      = 'mamba';
      Uber       = 'uber';
      Telegram   = 'telegram';
      Badoo      = 'badoo';
      Drugvokrug = 'drugvokrug';
      Avito      = 'avito';
      Olx        = 'olx';
      Steam      = 'steam';
      Fotostrana = 'fotostrana';
      Microsoft  = 'microsoft';
      Viber      = 'viber';
      WhatsApp   = 'whatsapp';
      WeChat     = 'WeChat';
      SeoSprint  = 'seosprint';
      Instagram  = 'instagram';
      Yahoo      = 'yahoo';
      LineMe     = 'lineme';
      KakaoTalk  = 'kakaotalk';
      Meetme     = 'meetme';
      Tinder     = 'tinder';
      Nimses     = 'nimses';
      Youla      = 'youla';
      Pyaterka   = '5ka';
      Other      = 'other';
    end;

    Exc = class sealed
    type
      Base = class abstract(Exception)
      private
        fUrl: string;
      public
        property Url: string read fUrl;

        constructor Create(message: string; url: string);
      end;
      NetworkError = class(Base);
      ResponseError = class(Base)
      private
        fResponse: string;
      public
        property Response: string read fResponse;

        constructor Create(message: string; response, url: string);
      end;
    end;
  public
    class function NewClient(apiKey: string; httpClient: ISmsRegHttpClient): ISmsRegClient;
  end;

implementation

type
  TSmsRegClient = class(TInterfacedObject,  ISmsRegClient)
  private
    fHttpClient: ISmsRegHttpClient;
    fApiKey: string;

    function SendRequest(endpoint: string; params: TArray<string>): ISuperObject; overload;
    function SendRequest<T>(endpoint: string; params: TArray<string>): T; overload;
  protected
    function GetNumber(service: string; country: string): string;
    procedure SetReady(tzid: string);
  public
    constructor Create(apiKey: string; httpClient: ISmsRegHttpClient);
  end;

{ TSmsRegClient }

constructor TSmsRegClient.Create(apiKey: string; httpClient: ISmsRegHttpClient);
begin
  fApiKey     := apiKey;
  fHttpClient := httpClient;
end;

function ArrayToParams(params: TArray<string>): string;
var
  i: integer;
  p: string;
begin
  i := 0;
  while i < Length(params) do
  begin
    if not p.IsEmpty() then
      p := p + '&';
    if not string.IsNullOrEmpty(params[i + 1]) then
      p := p + params[i] + '=' + params[i + 1];
    Inc(i, 2);
  end;
  Result := p;
end;

function TSmsRegClient.SendRequest(endpoint: string;
  params: TArray<string>): ISuperObject;
var
  url: string;
  response: string;
  j: ISuperObject;

  baseResp: SmsReg.Responses.Base;
begin
  url := Format(
    'http://api.sms-reg.com/%s.php?apikey=%s&%s',
    [endpoint, fApiKey, ArrayToParams(params)]);

  try
    response := fHttpClient.Get(url);
  except
    on E: Exception do
      Exception.RaiseOuterException(
        SmsReg.Exc.NetworkError.Create('network error: ' + E.Message, url));
  end;
  try
    j := SO(response);
    baseResp := TJson.Parse<SmsReg.Responses.Base>(j);
  except
    on E: Exception do
      Exception.RaiseOuterException(
        SmsReg.Exc.ResponseError.Create(
          'response error: ' + E.Message, response, url));
  end;
  if baseResp.Status <> '1' then
  begin
    if baseResp.Error.IsEmpty() then
      raise SmsReg.Exc.ResponseError.Create(
        'unrecognized response', response, url)
    else
      raise SmsReg.Exc.ResponseError.Create(
        'response error: ' + baseResp.Error, response, url);
  end;
  Result := j;
end;

function TSmsRegClient.SendRequest<T>(endpoint: string;
  params: TArray<string>): T;
var
  j: ISuperObject;
begin
  j := SendRequest(endpoint, params);
  Result := TJson.Parse<T>(j);
end;

function TSmsRegClient.GetNumber(service: string; country: string): string;
begin
  if string.IsNullOrEmpty(service) then
    raise EArgumentException.Create('service param is cannot be null or empty');

  Result := SendRequest<SmsReg.Responses.GetNumber>('getNum',
    ['country', country,
     'service', service]).tzid;
end;

procedure TSmsRegClient.SetReady(tzid: string);
begin
  SendRequest('setReady', ['tzid', tzid]);
end;

{ SmsReg }

class function SmsReg.NewClient(apiKey: string; httpClient: ISmsRegHttpClient): ISmsRegClient;
begin
  Result := TSmsRegClient.Create(apiKey, httpClient);
end;

{ SmsReg.Exc.Base }

constructor SmsReg.Exc.Base.Create(message, url: string);
begin
  inherited Create(message);
  fUrl := url;
end;

{ SmsReg.Exc.ResponseError }

constructor SmsReg.Exc.ResponseError.Create(message, response, url: string);
begin
  inherited Create(message, url);
  fResponse := response;
end;

end.
