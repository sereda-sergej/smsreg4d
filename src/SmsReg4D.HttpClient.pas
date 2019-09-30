unit SmsReg4D.HttpClient;

interface

type
  IHttpClient = interface
    function Get(url: string): string;
  end;

implementation

end.
