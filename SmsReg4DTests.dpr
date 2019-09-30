program SmsReg4DTests;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  SmsReg4D in 'src\SmsReg4D.pas',
  SmsReg4D.Synapse in 'src\SmsReg4D.Synapse.pas';

type
  THttpClientProxy = class(TInterfacedObject, ISmsRegHttpClient)
  strict private
    fHttpClient: ISmsRegHttpClient;
  protected
    function Get(url: string): string;
  public
    constructor Create(original: ISmsRegHttpClient);
  end;

{ THttpClientProxy }

constructor THttpClientProxy.Create(original: ISmsRegHttpClient);
begin
  fHttpClient := original;
end;

function THttpClientProxy.Get(url: string): string;
begin
  if url.Contains('getNum') then
    Exit('{"response": "1", "tzid":"123"}');
  Result := fHttpClient.Get(url);
end;

var
  client: ISmsRegClient;

begin
  client := SmsReg.NewClient('4zi3xxmmwbmwysvg197a43klddii315o', THttpClientProxy.Create(TSmsRegSynapse.Create()));
  try
    Writeln(client.GetNumber(SmsReg.Services.Vk));
  except
    on E: SmsReg.Exc.ResponseError do
      Writeln(E.Message, ' url: ', E.Url, ', response: ', E.Response);
  end;
  Readln;
end.
