unit SmsReg4D.Responses;

interface

uses
  XSuperObject;

type
  TSmsRegResponses = class
  type
    GetNumber = class
      [Alias('tzid')]
      tzid: string;
    end;
  end;

  TGetNumResponse = class

    [Alias('tzid')]
    tzid: string;

  end;

implementation

end.
