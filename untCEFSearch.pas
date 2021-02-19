unit untCEFSearch;

interface

uses System.SysUtils, uCEFInterfaces;

function FindNodeByClass(ANode: ICefDomNode; NodeName, AClassName: string): ICefDomNode;
function FindNodeByAttrEx(ANode: ICefDomNode; NodeName, AttrName, AttrValue: string): ICefDomNode;

implementation

function FindNodeByClass(ANode: ICefDomNode; NodeName, AClassName: string): ICefDomNode;
begin
  Result := FindNodeByAttrEx(ANode, NodeName, 'class', AClassName);
end;

function FindNodeByAttrEx(ANode: ICefDomNode; NodeName, AttrName, AttrValue: string): ICefDomNode;
var
  I: Integer;
  child: ICefDomNode;
  str: string;
begin
  Result := nil;
  if ANode = nil then
    Exit(nil);
//  OutputDebugString(PChar('FindNodeByAttrEx: ' + NodeName + '_' +  AttrName + '_' +  AttrValue + ' in ' +  ANode.tagName + ':' + ANode.classname));
  if Sametext(ANode.Name, NodeName) then
  begin
    if AttrName.IsEmpty then
      Result := ANode
    else // для иных атрибутов
    begin
      str := ANode.GetElementAttribute(AttrName);
      if AttrValue.IsEmpty or SameText(str, AttrValue) then
        Result := ANode
    end
  end;
  child := ANode.FirstChild;
  if not Assigned(Result) and Assigned(child) then
    while Assigned(child) do
    begin
      Result := FindNodeByAttrEx(child, NodeName, AttrName, AttrValue);
      if Result <> nil then
        Exit;
      child := child.NextSibling;
    end;

end;


end.
