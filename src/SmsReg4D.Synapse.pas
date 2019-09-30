unit SmsReg4D.Synapse;

interface

uses
  SmsReg4D;

type
  TSmsRegSynapse = class(TInterfacedObject, ISmsRegHttpClient)
  protected
    function Get(url: string): string;
  end;

implementation

uses
  httpsend,
  synautil;

{ TSmsRegSynapse }

function TSmsRegSynapse.Get(url: string): string;
var
  http: THttpSend;
begin
  http := THttpSend.Create();
  try
    http.Protocol := '1.1';

    http.Sock.RaiseExcept := True;

    http.HTTPMethod('GET', url);

    Result := ReadStrFromStream(http.Document, http.Document.Size);
  finally
    http.Free();
  end;

end;

end.
