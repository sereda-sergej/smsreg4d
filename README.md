# smsreg4d
Delphi api client for sms-reg.com

## Example
```delphi
uses
  SmsReg4D,
  SmsReg4D.Synapse;

var
  client: ISmsRegClient;
  tzid: string;

begin
  client := SmsReg.NewClient('api_key', TSynapseSmsReg.Create());

  tzid := client.GetNumber('instagram');
  client.SetReady(tzid);

  //...
end.

```

## Dependencies
* [x-superobject](https://github.com/onryldz/x-superobject)