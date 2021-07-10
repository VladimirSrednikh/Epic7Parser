unit untCEFSearch;

interface

uses System.SysUtils, System.StrUtils, System.Generics.Defaults, System.Generics.Collections,

  uCEFInterfaces, uCEFMiscFunctions, uCEFConstants, uCEFTypes;

type
  TCefDomNodeTypeSet = set of TCefDomNodeType;


function FindNodeByClass(ANode: ICefDomNode; NodeName, AClassName: string): ICefDomNode;
function FindNodeByAttrEx(ANode: ICefDomNode; NodeName, AttrName, AttrValue: string; ALvl: Integer = 0): ICefDomNode;
procedure FillNodeArrByAttrEx(ANode: ICefDomNode; NodeName, AttrName, AttrValue: string; var Res: TList<ICefDomNode>);

function GetNodeValByAttrEx(ANode: ICefDomNode; NodeName, AttrName, AttrValue: string): string;
function GetNodeText(ANode: ICefDomNode): string;

function GetChildByNo(ANode: ICefDomNode; AIndex: Integer; IgnoreNodeTypes: TCefDomNodeTypeSet = [DOM_NODE_TYPE_TEXT]): ICefDomNode;
function GetChildCount(ANode: ICefDomNode; IgnoreNodeTypes: TCefDomNodeTypeSet = [DOM_NODE_TYPE_TEXT]): Integer;

implementation

function FindNodeByClass(ANode: ICefDomNode; NodeName, AClassName: string): ICefDomNode;
begin
  Result := FindNodeByAttrEx(ANode, NodeName, 'class', AClassName);
end;

function FindNodeByAttrEx(ANode: ICefDomNode; NodeName, AttrName, AttrValue: string; ALvl: Integer = 0): ICefDomNode;
var
  child: ICefDomNode;
  str: string;
  pref: string;
begin
  Result := nil;
  if ANode = nil then
    Exit(nil);
  pref := DupeString('+', ALvl);
//  CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, pref+Format('FindNodeByAttrEx: NodeName %s AttrName %s, AttrValue %s in <%s class="%s"> type %d',
//    [NodeName, AttrName, AttrValue, ANode.Name, ANode.GetElementAttribute('class'), Ord(ANode.NodeType)]));

  if Sametext(ANode.Name, NodeName) then
  begin
//    try
    if AttrName.IsEmpty then
      Result := ANode
    else // для иных атрибутов
//    if ANode.HasElementAttribute(AttrName) then
    begin
//      with child do
//      CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, pref+Format('child AttrName %s, HasElementAttribute %s', [AttrName, BoolToStr(ANode.HasElementAttribute(AttrName), True)]));
      str := ANode.GetElementAttribute(AttrName);
//      CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, pref+Format('GetElementAttribute %s', [str]));
      if AttrValue.IsEmpty or SameText(str, AttrValue) then
        Result := ANode
    end
//    except
//      CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, pref+'Error at FindNodeByAttrEx crash at HasElementAttribute');
//    end;
  end;

  if Assigned(Result) then Exit(Result);
  if not ANode.HasChildren then Exit(nil);

  child := ANode.FirstChild;
  if Assigned(child) then
//  try
    while Assigned(child) do
    begin
//      with child do
//      CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, pref+Format('child NodeType %d, Name %s, class "%s"', [Ord(NodeType), Name, GetElementAttribute('class')]));
//      CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'child.AsMarkup: ' + child.AsMarkup);
//      if child.NodeType <> DOM_NODE_TYPE_ELEMENT then
      begin
      Result := FindNodeByAttrEx(child, NodeName, AttrName, AttrValue, ALvl + 1);
      if Result <> nil then
        Exit;
      end;
      child := child.NextSibling;
//      if child <> nil then
//        CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, pref+'NextSibling for ' + ANode.Name + ' ' + ANode.GetElementAttribute('class'))
//      else
//        CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, pref+'NextSibling is nil');
    end;
//  except
//  CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, pref+'Error at FindNodeByAttrEx crash at Siblings');
//  end;
end;

procedure FillNodeArrByAttrEx(ANode: ICefDomNode; NodeName, AttrName, AttrValue: string; var Res: TList<ICefDomNode>);
var
  child: ICefDomNode;
  str: string;
begin
  if Res = nil then
    Res := TList<ICefDomNode>.Create;

  if ANode = nil then
    Exit;
//  with ANode do
//    CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, Format('ANode NodeType %d, Name %s, class "%s", val = "%s"', [Ord(NodeType), Name, GetElementAttribute('class'), GetNodeText(ANode)]));
  if SameText(ANode.Name, NodeName) then
  begin
    if AttrName.IsEmpty then
      Res.Add(ANode)
    else // для иных атрибутов
    begin
      with child do
      str := ANode.GetElementAttribute(AttrName);
      if AttrValue.IsEmpty or SameText(str, AttrValue) then
        Res.Add(ANode)
    end
  end;

  if not ANode.HasChildren then Exit;

  child := ANode.FirstChild;
  if Assigned(child) then
    while Assigned(child) do
    begin
      FillNodeArrByAttrEx(child, NodeName, AttrName, AttrValue, Res);
      child := child.NextSibling;
    end;
end;

function GetNodeValByAttrEx(ANode: ICefDomNode; NodeName, AttrName, AttrValue: string): string;
var
  res: ICefDomNode;
begin
  res := FindNodeByAttrEx(ANode, NodeName, AttrName, AttrValue);
  if Assigned(res) then
    Result := res.GetValue
  else
    Result := '';
end;

function GetChildByNo(ANode: ICefDomNode; AIndex: Integer; IgnoreNodeTypes: TCefDomNodeTypeSet): ICefDomNode;
var
  I: Integer;
  child: ICefDomNode;
begin
  if (ANode = nil) or not ANode.HasChildren then Exit(nil);
  child := ANode.FirstChild;
  I := 0;
  while AIndex > 0 do
  begin
    if not (child.NodeType in IgnoreNodeTypes) then
      Inc(I);
    if I = AIndex then
      Exit(child)
    else
      child := child.NextSibling;
  end;
end;

function GetChildCount(ANode: ICefDomNode; IgnoreNodeTypes: TCefDomNodeTypeSet): Integer;
var
  child: ICefDomNode;
begin
  Result := 0;
  if (ANode = nil) or not ANode.HasChildren then Exit;
  child := ANode.FirstChild;
  while child <> nil do
  begin
    if not (child.NodeType in IgnoreNodeTypes) then
      Inc(Result);
    child := child.NextSibling;
  end;
end;

function GetNodeText(ANode: ICefDomNode): string;
var
  child: ICefDomNode;
begin
  child := ANode.FirstChild;
  while Assigned(child) do
  begin
    if child.IsText then
    begin
      Result := child.GetValue;
      Result := StringReplace(Result, #10, '', [rfReplaceAll]);
      Result := StringReplace(Result, #13, '', [rfReplaceAll]);
      Result := Trim(Result);
    end;
    child := child.NextSibling;
  end;
end;

end.
