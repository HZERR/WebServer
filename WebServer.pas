unit WebServer;

interface

uses
  System.SysUtils, System.Classes, Web.HTTPApp, Data.DB, Data.SqlExpr;

type
  TWebModule1 = class(TWebModule)
    procedure WebModule1DefaultHandlerAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    function GetJSONData(const SQL: string): string;
  public
    { Public declarations }
  end;

var
  WebModule1: TWebModule1;

implementation

{$R *.dfm}

function TWebModule1.GetJSONData(const SQL: string): string;
var
  conn: TSQLConnection;
  qry: TSQLQuery;
  json: string;
begin
  conn := TSQLConnection.Create(nil);
  qry := TSQLQuery.Create(nil);
  try
    conn.DriverName := 'MSSQL';
    conn.Params.Values['HostName'] := 'KOMPUTER\SQLEXPRESS';
    conn.Params.Values['Database'] := 'TourismDB';
    conn.Params.Values['User_Name'] := 'HZERR';
    conn.Params.Values['Password'] := 'Password123456';
    conn.LoginPrompt := False;
    conn.Connected := True;

    qry.SQLConnection := conn;
    qry.SQL.Text := SQL;
    qry.Open;

    json := '[';
    while not qry.Eof do
    begin
      json := json + Format('{"id":%d,"name":"%s"}',
        [qry.FieldByName('ClientID').AsInteger,
         qry.FieldByName('Name').AsString]);
      qry.Next;
      if not qry.Eof then
        json := json + ',';
    end;
    json := json + ']';
    
    Result := json;
  finally
    qry.Free;
    conn.Free;
  end;
end;

procedure TWebModule1.WebModule1DefaultHandlerAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
  if Request.PathInfo = '/clients' then
  begin
    Response.ContentType := 'application/json';
    Response.Content := GetJSONData('SELECT ClientID, Name FROM Client');
  end
  else
  begin
    Response.Content := 
      '<h1>Туристическое WEB-приложение</h1>' +
      '<p>Доступные endpoints:</p>' +
      '<ul>' +
      '<li><a href="/clients">/clients</a> - список клиентов (JSON)</li>' +
      '</ul>';
    Response.ContentType := 'text/html; charset=utf-8';
  end;
  
  Handled := True;
end;

end.