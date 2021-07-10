unit untMainForm;
{$I cef.inc}
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.SyncObjs, System.Classes, Vcl.Graphics, Vcl.Menus, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Types,
  Vcl.ComCtrls, Vcl.ClipBrd, System.UITypes, System.StrUtils,
  System.Generics.Defaults, System.Generics.Collections,
  superobject,
  untCEFSearch, uCEFStringMap,
  uCEFChromium, uCEFWindowParent, uCEFInterfaces, uCEFApplication, uCEFTypes,
  uCEFConstants, uCEFWinControl, uCEFSentinel, uCEFChromiumCore;
const
  MINIBROWSER_VISITDOM_PARTIAL            = WM_APP + $101;
  MINIBROWSER_VISITDOM_FULL               = WM_APP + $102;
  MINIBROWSER_COPYFRAMEIDS_1              = WM_APP + $103;
  MINIBROWSER_COPYFRAMEIDS_2              = WM_APP + $104;
  MINIBROWSER_SHOWMESSAGE                 = WM_APP + $105;
  MINIBROWSER_SHOWSTATUSTEXT              = WM_APP + $106;
  MINIBROWSER_VISITDOM_JS                 = WM_APP + $107;
  MINIBROWSER_CONTEXTMENU_VISITDOM_PARTIAL = MENU_ID_USER_FIRST + 1;
  MINIBROWSER_CONTEXTMENU_VISITDOM_FULL    = MENU_ID_USER_FIRST + 2;
  MINIBROWSER_CONTEXTMENU_COPYFRAMEIDS_1   = MENU_ID_USER_FIRST + 3;
  MINIBROWSER_CONTEXTMENU_COPYFRAMEIDS_2   = MENU_ID_USER_FIRST + 4;
  MINIBROWSER_CONTEXTMENU_VISITDOM_JS      = MENU_ID_USER_FIRST + 5;
  MINIBROWSER_CONTEXTMENU_SETINPUTVALUE_JS = MENU_ID_USER_FIRST + 6;
  DOMVISITOR_MSGNAME_PARTIAL  = 'domvisitorpartial';
  DOMVISITOR_MSGNAME_FULL     = 'domvisitorfull';
  RETRIEVEDOM_MSGNAME_PARTIAL = 'retrievedompartial';
  RETRIEVEDOM_MSGNAME_FULL    = 'retrievedomfull';
  FRAMEIDS_MSGNAME            = 'getframeids';
  CONSOLE_MSG_PREAMBLE        = 'DOMVISITOR';
  NODE_ID = 'keywords';

  DOMVISITOR_PARSE_LIST = 'domvisitor_parse_list';
  DOMVISITOR_PARSE_HEROSET = 'domvisitor_parse_hero_set';
  C_WORK_DONE  = 'Epic7_Parser_workDone';
  C_Epic7_Hero = 'Epic7_Hero';
type
  TfrmEpic7xParser = class(TForm)
    CEFWindowParent1: TCEFWindowParent;
    Chromium1: TChromium;
    AddressBarPnl: TPanel;
    AddressEdt: TEdit;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    Panel1: TPanel;
    GoBtn: TButton;
    btnParseHeroInfo: TButton;
    ProgressBar1: TProgressBar;
    Splitter1: TSplitter;
    btnParseHeroList: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure GoBtnClick(Sender: TObject);
    procedure btnParseHeroInfoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Chromium1AfterCreated(Sender: TObject; const browser: ICefBrowser);
    procedure Chromium1BeforeContextMenu(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; const params: ICefContextMenuParams; const model: ICefMenuModel);
    procedure Chromium1ContextMenuCommand(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; const params: ICefContextMenuParams; commandId: Integer; eventFlags: Cardinal; out Result: Boolean);
    procedure Chromium1ProcessMessageReceived(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; sourceProcess: TCefProcessId; const message: ICefProcessMessage; out Result: Boolean);
    procedure Chromium1BeforePopup(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; const targetUrl, targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition; userGesture: Boolean; const popupFeatures: TCefPopupFeatures; var windowInfo: TCefWindowInfo; var client: ICefClient; var settings: TCefBrowserSettings; var extra_info: ICefDictionaryValue; var noJavascriptAccess: Boolean; var Result: Boolean);
    procedure Chromium1Close(Sender: TObject; const browser: ICefBrowser; var aAction : TCefCloseBrowserAction);
    procedure Chromium1BeforeClose(Sender: TObject; const browser: ICefBrowser);
    procedure Chromium1ConsoleMessage(Sender: TObject; const browser: ICefBrowser; level: Cardinal; const message, source: ustring; line: Integer; out Result: Boolean);
    procedure Chromium1DocumentAvailableInMainFrame(Sender: TObject;
      const browser: ICefBrowser);

    procedure Chromium1BeforeResourceLoad(Sender: TObject;
      const browser: ICefBrowser; const frame: ICefFrame;
      const request: ICefRequest; const callback: ICefRequestCallback;
      out Result: TCefReturnValue);
    procedure btnParseHeroListClick(Sender: TObject);

  protected
    // Variables to control when can we destroy the form safely
    FCanClose : boolean;  // Set to True in TChromium.OnBeforeClose
    FClosing  : boolean;  // Set to True in the CloseQuery event.
    // Critical section and fields to show information received in CEF events safely.
    FCritSection : TCriticalSection;
    FMsgContents : string;
    FStatusText  : string;
    FWorkDone: TEvent;
    FMainFrameLoading: Boolean;
    procedure NavigateAndWait(const AUrl: string);
    function  GetMsgContents : string;
    function  GetStatusText : string;
    procedure SetMsgContents(const aValue : string);
    procedure SetStatusText(const aValue : string);
    procedure BrowserCreatedMsg(var aMessage : TMessage); message CEF_AFTERCREATED;
    procedure BrowserDestroyMsg(var aMessage : TMessage); message CEF_DESTROY;
    procedure VisitDOMMsg(var aMessage : TMessage); message MINIBROWSER_VISITDOM_PARTIAL;
    procedure VisitDOM2Msg(var aMessage : TMessage); message MINIBROWSER_VISITDOM_FULL;
    procedure VisitDOM3Msg(var aMessage : TMessage); message MINIBROWSER_VISITDOM_JS;
    procedure CopyFrameIDs1(var aMessage : TMessage);  message MINIBROWSER_COPYFRAMEIDS_1;
    procedure CopyFrameIDs2(var aMessage : TMessage);  message MINIBROWSER_COPYFRAMEIDS_2;
    procedure ShowMessageMsg(var aMessage : TMessage);  message MINIBROWSER_SHOWMESSAGE;
    procedure ShowStatusTextMsg(var aMessage : TMessage);  message MINIBROWSER_SHOWSTATUSTEXT;
    procedure WMMove(var aMessage : TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage : TMessage); message WM_MOVING;
    procedure ShowStatusText(const aText : string);
    property  MsgContents : string   read GetMsgContents  write SetMsgContents;
    property  StatusText  : string   read GetStatusText   write SetStatusText;
  end;
var
  frmEpic7xParser: TfrmEpic7xParser;
procedure CreateGlobalCEFApp;
implementation
{$R *.dfm}
uses
  uCEFProcessMessage, uCEFMiscFunctions, uCEFSchemeRegistrar,
  uCEFRenderProcessHandler, uCEFv8Handler, uCEFDomVisitor, uCEFDomNode,
  uCEFTask;
// This demo sends messages from the browser process to the render process,
// and from the render process to the browser process.
// To send a message from the browser process you must use the
// TChromium.SendProcessMessage procedure with a PID_RENDERER parameter. The
// render process receives those messages in the
// GlobalCEFApp.OnProcessMessageReceived event.
// To send messages from the render process you must use the
// frame.SendProcessMessage procedure with a PID_BROWSER parameter. The browser
// process receives those messages in the TChromium.OnProcessMessageReceived
// event.
// message.name is used to identify different messages sent with
// SendProcessMessage.
// The OnProcessMessageReceived event can recognize any number of messages
// identifying them by message.name
// The CEF API is not as powerful as JavaScript to visit the DOM. Consider using
// TChromium.ExecuteJavaScript to execute custom JS code in case you need more
// powerful features.
// Read the code comments in the JSExtension demo for more information about the
// Chromium processes and how to send messages between them :
// https://github.com/salvadordf/CEF4Delphi/blob/master/demos/Delphi_VCL/JavaScript/JSExtension/uJSExtension.pas
// This demo also uses de "console trick" to send information from the render
// process to the browser process.
// This method for sending text messages is limited to around 10000 characters
// but it's much easier to implement than using a JavaScript extension.
// It cosist of using the JavaScript command "console.log" with a known text
// preamble. The browser process receives the console message in the
// TChromium.OnConsoleMessage event and we identify the right message thanks to
// the preamble in the message.
// Destruction steps
// =================
// 1. FormCloseQuery sets CanClose to FALSE calls TChromium.CloseBrowser which
//    triggers the TChromium.OnClose event.
// 2. TChromium.OnClose sends a CEFBROWSER_DESTROY message to destroy
//    CEFWindowParent1 in the main thread, which triggers the
//    TChromium.OnBeforeClose event.
// 3. TChromium.OnBeforeClose sets FCanClose := True and sends WM_CLOSE to the
//    form.
procedure SignalWorkIsDone;
begin
  with TEvent.Create(nil, True, False, C_WORK_DONE) do
  begin
    SetEvent;
    Free;
  end;
end;
procedure EnumSubNodes(ANode: ICefDomNode);
var
  I: Integer;
  Cell: ICefDomNode;
begin
  for I := 1 to GetChildCount(ANode) do
  begin
    Cell := GetChildByNo(ANode, I);
    CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, Format('=========== Cell[%d] %d - %s', [i, Ord(Cell.NodeType), Cell.AsMarkup]));
  end;
end;
procedure SimpleDOMIteration(const aDocument: ICefDomDocument);
var
  TempHead, TempChild : ICefDomNode;
begin
  try
    if (aDocument <> nil) then
      begin
        TempHead := aDocument.Head;
        if (TempHead <> nil) then
          begin
            TempChild := TempHead.FirstChild;
            while (TempChild <> nil) do
              begin
                CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, 'Head child element : ' + TempChild.Name);
                TempChild := TempChild.NextSibling;
              end;
          end;
      end;
  except
    on e : exception do
      if CustomExceptionHandler('SimpleDOMIteration', e) then raise;
  end;
end;
procedure SimpleNodeSearch(const aDocument: ICefDomDocument; const aFrame : ICefFrame);
var
  TempNode : ICefDomNode;
  TempJSCode, TempMessage : string;
begin
  try
    if (aDocument <> nil) then
      begin
        TempNode := aDocument.GetElementById(NODE_ID);
        if (TempNode <> nil) then
          begin
            // Here we send the name and value of the element with the "console trick".
            // The name and value contents are included in TempMessage and the we
            // execute "console.log" in JavaScript to send TempMessage with a
            // known preamble that will be used to identify the message in the
            // TChromium.OnConsoleMessage event.
            // CEF has some known issues with ICefDomNode.GetValue and ICefDomNode.SetValue
            // Use JavaScript if you need to get or set the value of HTML elements.
            // For example, if you want to use the "console trick" and you want
            // to get the value of the search box in our forum you would have to
            // execute this JavaScript code :
            // console.log("DOMVISITOR" + document.getElementById("keywords").value);
            TempMessage := 'name:' + quotedstr(TempNode.Name);
            TempJSCode  := 'console.log("' + CONSOLE_MSG_PREAMBLE + TempMessage + '");';
            aFrame.ExecuteJavaScript(TempJSCode, 'about:blank', 0);
          end;
        TempNode := aDocument.GetFocusedNode;
        if (TempNode <> nil) then
          begin
            CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, 'Focused element name : ' + TempNode.Name);
            CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, 'Focused element inner text : ' + TempNode.ElementInnerText);
          end;
      end;
  except
    on e : exception do
      if CustomExceptionHandler('SimpleNodeSearch', e) then raise;
  end;
end;
procedure ParseHeroList(const browser: ICefBrowser; const frame: ICefFrame; const document: ICefDomDocument);
  function GetFileName(AUrl: string): string;
  var
    ind: Integer;
    strs: TArray<string>;
  begin
    strs := AUrl.Split(['/']);
    Result := strs[High(strs)];
    ind := LastDelimiter('.', Result);
    if ind > 0 then
      Result := Copy(Result, 1, ind -1);
  end;
  procedure parseOneHero(AHeroNode: ICefDomNode; AHeroCollection: ISuperObject);
  var
    node: ICefDomNode;
    heroObj: ISuperObject;
    lname: string;
  begin
    node := FindNodeByAttrEx(AHeroNode, 'span', 'class', 'f-12 char-name');
    if Assigned(node) then
    begin
      lname := GetNodeText(node);
CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, ' Hero name:' + lname);
      heroObj := SO();
      AHeroCollection.AsArray.Add(heroObj);
      heroObj.S['name'] := lname;
      heroObj.S['star'] := GetNodeText(AHeroNode.FirstChild);
//<img src="https://epic7x.com/wp-content/themes/epic7x/assets/img/Fire.png" class="tier-list-element">
//<img src="https://epic7x.com/wp-content/themes/epic7x/assets/img/Soul Weaver.png" class="tier-list-class">
      node := FindNodeByClass(AHeroNode, 'img', 'tier-list-element');
      if Assigned(node) then
        heroObj.S['element'] := GetFileName(node.GetElementAttribute('src'));
      node := FindNodeByClass(AHeroNode, 'img', 'tier-list-class');
      if Assigned(node) then
        heroObj.S['class'] := GetFileName(node.GetElementAttribute('src'));
      node := FindNodeByAttrEx(AHeroNode, 'a', 'href', '');
      if Assigned(node) then
        heroObj.S['Url'] := node.GetElementAttribute('href');
//      heroObj.O['sets'] := SA([]);
    end;
  end;
var
  TempNode : ICefDomNode;
  obj: ISuperObject;
  hero: ICefDomNode;
begin
  try
    if (document <> nil) then
    begin
      CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=============START : ' + IntToStr(GetTickCount));
      TempNode := document.GetElementById('app');
      if (TempNode <> nil) then
      begin
//        <div class="pure-u-1 mt-20">
//        TempNode := FindNodeByAttrEx(TempNode, 'div', 'class', 'pure-u-1 mt-20');
        TempNode := FindNodeByAttrEx(TempNode, 'table', '', '');
        if TempNode <> nil then
        begin
          TempNode := FindNodeByAttrEx(TempNode, 'tbody', '', '');
          if TempNode <> nil then
          begin
            hero := TempNode.FirstChild;
            obj := superobject.SA([]);
            try
              while Assigned(hero) do
              begin
                parseOneHero(hero, obj);
                hero := hero.NextSibling;
              end;
            finally
              CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '===========END : ' + IntToStr(GetTickCount) + ' ' + IntToStr(GetCurrentProcessId));
              obj.SaveTo(ChangeFileExt(ParamStr(0), '.json'), True, True);
              SignalWorkIsDone;
            end;
          end
        end
      end
    end
  except
    on e : exception do
    begin
      CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, 'Error!!! : ' + E.ClassName + ' ' + E.Message);
      if CustomExceptionHandler('SimpleNodeSearch', e) then raise;
    end;
  end;
end;

procedure LogNode(ANodeName: string; ANode: ICefDomNode);
var
  tmpstr: string;
begin
  if ANode = nil then
    CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo ' + ANodeName + ' ' + 'nil')
  else
  begin
    tmpstr := ANode.AsMarkup;
    CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo ' + ANodeName + ' - Ok'{. AsMarkup = ' + tmpstr});
  end;
end;
function GetPictureNameFromUrl(AUrl: string): string;
var
  arr: TStringDynArray;
begin
  arr := SplitString(AUrl, '/');
  Result := arr[High(arr)];
  Result := StringReplace(Result, '.jpg', '', [rfreplaceAll]);
  Result := StringReplace(Result, '.png', '', [rfreplaceAll]);
  Result := StringReplace(Result, '-', ' ', [rfreplaceAll]);
end;

function GetLinkNameFromUrl(AUrl: string): string;
var
  arr: TStringDynArray;
begin
  if EndsStr('/', AUrl) then
    AUrl := Copy(AUrl, 1, Length(AUrl) - 1);
  arr := SplitString(AUrl, '/');
  Result := arr[High(arr)];
  Result := StringReplace(Result, '-', ' ', [rfreplaceAll]);
end;


procedure ParseHeroBaseInfo(document: ICefDomDocument; AHero: ISuperObject);
var
  AppNode, ParamTable, ParamRow, Cell: ICefDomNode;
  ref: string;
begin
  AppNode := document.GetElementById('app'); //LogNode('app', AppNode);
  ParamTable := FindNodeByClass(AppNode, 'div', 'pure-g'); //LogNode('pure-g', ParamTable);
  ParamTable := GetChildByNo(ParamTable, 1);
  ParamRow := GetChildByNo(ParamTable, 4);
//          EnumSubNodes(ParamRow);
  if ParamRow <> nil then
  begin
    Cell := GetChildByNo(ParamRow, 3);
    Cell := FindNodeByAttrEx(Cell, 'img', '', '');
    ref := Cell.GetElementAttribute('data-src');
//            CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo Zodiac ref ' + ref);
    AHero.S['Zodiac'] := GetPictureNameFromUrl(ref);
//    CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo Zodiac: ' + AHero.S['Zodiac']);
  end;
end;

procedure ParseHeroInfoTierList(document: ICefDomDocument; AHero: ISuperObject);
//RECOMMENDED ARTIFACTS
//RECOMMENDED SETS
//SUBSTAT PRIORITY
const
  AddStats: array [1..3] of string = ('necklace', 'ring', 'boot');
var
  TierList,ListNode, ArtifactNode, SubstatNode, Cell, SetNode: ICefDomNode;
  buildNode, buildNameNode, buildKindNode, buildStatNode: ICefDomNode;
  I, iset, istat, statCnt: Integer;
  Substats: string;
  Res: TList<ICefDomNode>;
  build: ISuperObject;
begin
//  section id="TierList"
//      <div class="pure-g ">
  TierList := document.GetElementById('TierList');
  ListNode := GetChildByNo(TierList, 8);
//  CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== Parse Recomended Artefacts, AsMarkup = ' + ListNode.AsMarkup);
  AHero.O['artefacts'] := SA([]);

  if (ListNode <> nil) then
    for I := 1 to GetChildCount(ListNode) do
    begin
//  CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, 'Artefact, row #' + IntToStr(I) + ' from ' + GetChildCount(ListNode).ToString);
      Cell := GetChildByNo(ListNode, I);
      ArtifactNode := FindNodeByClass(Cell, 'div', 'f-12');
//  CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== Artefact: ' + GetNodeText(ArtifactNode));
      AHero.A['artefacts'].Add(GetNodeText(ArtifactNode));
    end;

  // Sets
  AHero.O['Builds'] := SA([]);
  ListNode := GetChildByNo(TierList, 12);
  if (ListNode <> nil) then
  for I := 1 to GetChildCount(ListNode) do
  begin
    buildNode := GetChildByNo(ListNode, I);

    buildNameNode := GetChildByNo(buildNode, 1);
    buildKindNode := GetChildByNo(buildNode, 2);
    buildStatNode := GetChildByNo(buildNode, 3);
    build := SO();
    AHero.A['Builds'].Add(build);
    build.S['name'] := GetNodeText(FindNodeByClass(buildNameNode, 'b', ''));
    build.O['sets'] := SA([]);

    for iset := 1 to GetChildCount(buildKindNode) do
    begin
      SetNode := FindNodeByClass(GetChildByNo(buildKindNode, iset), 'span', 'f-16');
      if SetNode <> nil then
        build.A['sets'].Add(GetNodeText(SetNode));
    end;

    statCnt := 0;
    for istat := 1 to GetChildCount(buildStatNode) do
    begin
      if statCnt > 3 then
        Break;
      Cell := GetChildByNo(buildStatNode, istat);
      if Cell.GetElementAttribute('class') = 'f-14' then
      begin
        statCnt := statCnt + 1;
//  CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo stat text : ' + GetNodeText(Cell));
//  CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo stat : ' + Cell.AsMarkup);
        build.S[AddStats[statCnt]] := Trim(StringReplace(GetNodeText(Cell), #$A0, '', [rfReplaceAll]));
      end;
    end;
  end;
//SUBSTAT PRIORITY
  AHero.O['Substats'] := SA([]);

  SubstatNode := document.GetElementById('SubstatPriority');
//  LogNode('SubstatPriority by ID', SubstatNode);
  if SubstatNode = nil then
  begin
//  <section class="pure-u-1 " id="SubstatPriority">
    SubstatNode := FindNodeByAttrEx(document.Body, 'section', 'id', 'SubstatPriority');
//    LogNode('SubstatPriority by atribs', SubstatNode);
  end;

  if SubstatNode <> nil then
    ListNode := FindNodeByClass(SubstatNode, 'div', 'mp-20');
  LogNode('div mp-20', ListNode);
  if ListNode <> nil then
    begin
      Res := nil;
      try
        FillNodeArrByAttrEx(ListNode, 'b', '', '', Res);
//  CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo Found substats Count: ' + IntToStr(Res.Count));
        for SetNode in Res do
        begin
//        CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo Found substat: ' + GetNodeText(SetNode));
          Substats := GetNodeText(SetNode);
          AHero.A['Substats'].Add(Substats);
        end;
      finally
        Res.Free;
      end;
    end;
end;

procedure ParseHeroInfoCatalysts(document: ICefDomDocument; AHero: ISuperObject);
var
  SkillsNode, AwekeningNode,
  ParamTable, ParamRow, Cell,
  ListNode, RoleNode, SetsNode, SetNode: ICefDomNode;
  ref, CatalystName: string;
  i: Integer;
begin
  // Catalysts for skills
  SkillsNode := document.GetElementById('Skills'); LogNode('Skills', SkillsNode);
  ParamTable := FindNodeByClass(SkillsNode, 'div', 'pure-g mt-50 mmt-0');  //LogNode('pure-g mt-50 mmt-0', ParamTable);
  ParamTable := FindNodeByClass(ParamTable, 'div', 'pure-u-1 text-center mt-30 pb-50');  //LogNode('pure-u-1 text-center mt-30 pb-50', ParamTable);
  ParamTable := FindNodeByClass(ParamTable, 'div', 'pure-g');   LogNode('pure-g', ParamTable);
//          EnumSubNodes(ParamTable);
  for I := 1 to GetChildCount(ParamTable) do
  begin
    ParamRow := GetChildByNo(ParamTable, I);
//            CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, Format('=========== Skills ParamRow[%d] %d - %s', [i, Ord(ParamRow.NodeType), ParamRow.AsMarkup]));
    Cell := FindNodeByAttrEx(ParamRow, 'a', '', '');
    if Cell <> nil then
    begin
      ref := Cell.GetElementAttribute('href');
      CatalystName := GetLinkNameFromUrl(ref);
      CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, Format('=========== Skills ParamRow[%d] href %s, name %s', [i, ref, CatalystName]));
      if not SameText(CatalystName, 'gold') or not SameText(CatalystName, 'molagora') or not SameText(CatalystName, 'molagorago') then
        if AHero.O['Catalysts'].S[CatalystName] = '' then
        begin
          AHero.O['Catalysts'].S[CatalystName] := '+';
        end;
//              obj.O[heroName].A['Catalysts'].
    end;
  end;

  // Catalysts for awakening
  AwekeningNode := document.GetElementById('Awakening'); LogNode('Awakening', AwekeningNode);
  ParamTable := FindNodeByClass(AwekeningNode, 'div', 'pure-u-1 text-center mt-20');  LogNode('pure-u-1 text-center mt-20', ParamTable);
  ParamTable := FindNodeByClass(ParamTable, 'div', 'pure-g');  LogNode('pure-g', ParamTable);
//          EnumSubNodes(ParamTable);
  for I := 1 to GetChildCount(ParamTable) do
  begin
    ParamRow := GetChildByNo(ParamTable, I);
//            CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== awakening ParamRow[]' + inttoStr(i) + ' ' + ParamRow.AsMarkup);
    Cell := FindNodeByAttrEx(ParamRow, 'a', '', '');
    if Cell <> nil then
    begin
      ref := Cell.GetElementAttribute('href');
      CatalystName := GetLinkNameFromUrl(ref);
      CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, Format('=========== awakening ParamRow[%d] href %s, name %s', [i, ref, CatalystName]));
      if not ContainsText(CatalystName, ' rune') then
        if AHero.O['Catalysts'].S[CatalystName] = '' then
        begin
          AHero.O['Catalysts'].S[CatalystName] := '+';
        end;
    end;
  end;

end;

procedure ParseHeroInfoBaseStats(document: ICefDomDocument; AHero: ISuperObject);
begin


end;

procedure ParseHeroInfoBaseTeamCalc(document: ICefDomDocument; AHero: ISuperObject);
begin


end;

procedure ParseHeroInfo(const browser: ICefBrowser; const frame: ICefFrame; const document: ICefDomDocument);
  function GetHeroIndName(AHeroArr: ISuperObject; AHeroName: string): Integer;
  var
    i: Integer;
  begin
    for I := 0 to AHeroArr.AsArray.Length - 1 do
      if AHeroArr.AsArray[i].S['name'] = AHeroName then
        Exit(I);
    Result := -1;
  end;

var
  AppNode, NameNode,
  ParamTable, ParamRow, Cell,
  ListNode, RoleNode, SetsNode, SetNode: ICefDomNode;
  ref, CatalystName,
  heroName, setName, Substats: string;
  HeroesFile: ISuperObject;
  heroInd, I: Integer;
  st: Cardinal;
begin
  try
    if (document <> nil) then
    begin
      st := GetTickCount;
      CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo START : ');// + IntToStr(st));
      HeroesFile := TSuperObject.ParseFile(ChangeFileExt(ParamStr(0), '.json'), True);
      try
      // 1) Определить имя героя
        AppNode := document.GetElementById('app'); LogNode('app', AppNode);
        NameNode := FindNodeByClass(AppNode, 'h1', 'pt-30'); LogNode('pt-30 NameNode: ' + GetNodeText(NameNode), NameNode);
        heroName := GetNodeText(NameNode);
//        CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo Detect hero: ' + heroName);
        heroInd := GetHeroIndName(HeroesFile, heroName);
        if heroInd = -1 then
        begin
          CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo Hero not found');
          Exit;
        end;

      //2) Параметры героя:
        CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, 'Title: ' + document.BaseUrl + ' ' + document.Title);
        CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, 'Body: ' + InttoHex(Integer(TObject(document.body)), 8));
//        if document.body <> nil then
//        CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo RootNode ' + document.body.AsMarkup);
        ParseHeroBaseInfo(document, HeroesFile.AsArray[heroInd]);
        ParseHeroInfoTierList(document, HeroesFile.AsArray[heroInd]);
        ParseHeroInfoCatalysts(document, HeroesFile.AsArray[heroInd]);
        ParseHeroInfoBaseStats(document, HeroesFile.AsArray[heroInd]);
        ParseHeroInfoBaseTeamCalc(document, HeroesFile.AsArray[heroInd]);
        HeroesFile.SaveTo(ChangeFileExt(ParamStr(0), '.json'));
      finally
        CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== ParseHeroInfo END   : ' + IntToStr(GetTickCount - st));
        SignalWorkIsDone;
        HeroesFile.SaveTo(ChangeFileExt(ParamStr(0), '.json'), True, True);
      end;
    end
  except
    on e : exception do
    begin
      CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, 'Error!!! : ' + E.ClassName + ' ' + E.Message);
      if CustomExceptionHandler('SimpleNodeSearch', e) then raise;
    end;
  end;
end;
procedure DOMVisitor_OnDocAvailableFullMarkup(const browser: ICefBrowser; const frame: ICefFrame; const document: ICefDomDocument);
var
  TempMessage : ICefProcessMessage;
begin
  // Sending back some custom results to the browser process
  // Notice that the DOMVISITOR_MSGNAME_FULL message name needs to be recognized in
  // Chromium1ProcessMessageReceived
  try
    TempMessage := TCefProcessMessageRef.New(DOMVISITOR_MSGNAME_FULL);
    TempMessage.ArgumentList.SetString(0, document.Body.AsMarkup);
    if (frame <> nil) and frame.IsValid then
      frame.SendProcessMessage(PID_BROWSER, TempMessage);
  finally
    TempMessage := nil;
  end;
end;
procedure GlobalCEFApp_OnProcessMessageReceived(const browser       : ICefBrowser;
                                                const frame         : ICefFrame;
                                                      sourceProcess : TCefProcessId;
                                                const message       : ICefProcessMessage;
                                                var   aHandled      : boolean);
var
  TempVisitor : TCefFastDomVisitor2;
begin
  aHandled := False;
  if (browser <> nil) then
    begin
      if (message.name = DOMVISITOR_PARSE_LIST) then
        begin
          if (frame <> nil) and frame.IsValid then
            begin
              TempVisitor := TCefFastDomVisitor2.Create(browser, frame, ParseHeroList);
              frame.VisitDom(TempVisitor);
            end;
          aHandled := True;
        end
       else
      if (message.name = DOMVISITOR_PARSE_HEROSET) then
        begin
          if (frame <> nil) and frame.IsValid then
            begin
              TempVisitor := TCefFastDomVisitor2.Create(browser, frame, ParseHeroInfo);
              frame.VisitDom(TempVisitor);
            end;
          aHandled := True;
        end
    end;
end;
procedure CreateGlobalCEFApp;
begin
  GlobalCEFApp                          := TCefApplication.Create;
  GlobalCEFApp.RemoteDebuggingPort      := 9000;
  GlobalCEFApp.OnProcessMessageReceived := GlobalCEFApp_OnProcessMessageReceived;
  // Enabling the debug log file for then DOM visitor demo.
  // This adds lots of warnings to the console, specially if you run this inside VirtualBox.
  // Remove it if you don't want to use the DOM visitor
  GlobalCEFApp.LogFile              := 'debug.log';
  GlobalCEFApp.LogSeverity          := LOGSEVERITY_INFO;
  // Delphi can only debug one process and it debugs the browser process by
  // default. If you need to debug code executed in the render process you will
  // need to use any of the methods described here :
  // https://www.briskbard.com/index.php?lang=en&pageid=cef#debugging
  // Using the "Single process" mode is one of the ways to debug all the code
  // because everything is executed in the browser process and Delphi won't have
  // any problems. However, The "Single process" mode is unsupported by CEF and
  // it causes unexpected issues. You should *ONLY* use it for debugging
  // purposses.
  //GlobalCEFApp.SingleProcess := True;
end;
procedure TfrmEpic7xParser.Chromium1AfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  PostMessage(Handle, CEF_AFTERCREATED, 0, 0);
end;
procedure TfrmEpic7xParser.Chromium1BeforeClose(Sender: TObject;
  const browser: ICefBrowser);
begin
  FCanClose := True;
  PostMessage(Handle, WM_CLOSE, 0, 0);
end;
procedure TfrmEpic7xParser.Chromium1BeforeContextMenu(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; const model: ICefMenuModel);
begin
  model.AddItem(MINIBROWSER_CONTEXTMENU_VISITDOM_PARTIAL,  'Visit DOM in CEF (only Title)');
  model.AddItem(MINIBROWSER_CONTEXTMENU_VISITDOM_FULL,     'Visit DOM in CEF (BODY HTML)');
  model.AddItem(MINIBROWSER_CONTEXTMENU_VISITDOM_JS,       'Visit DOM using JavaScript');
  model.AddItem(MINIBROWSER_CONTEXTMENU_COPYFRAMEIDS_1,    'Copy frame IDs in the browser process');
  model.AddItem(MINIBROWSER_CONTEXTMENU_COPYFRAMEIDS_2,    'Copy frame IDs in the render process');
  model.AddItem(MINIBROWSER_CONTEXTMENU_SETINPUTVALUE_JS,  'Set INPUT value using JavaScript');
end;
procedure TfrmEpic7xParser.Chromium1BeforePopup(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; const targetUrl,
  targetFrameName: ustring; targetDisposition: TCefWindowOpenDisposition;
  userGesture: Boolean; const popupFeatures: TCefPopupFeatures;
  var windowInfo: TCefWindowInfo; var client: ICefClient;
  var settings: TCefBrowserSettings;
  var extra_info: ICefDictionaryValue;
  var noJavascriptAccess: Boolean;
  var Result: Boolean);
begin
  // For simplicity, this demo blocks all popup windows and new tabs
  Result := (targetDisposition in [WOD_NEW_FOREGROUND_TAB, WOD_NEW_BACKGROUND_TAB, WOD_NEW_POPUP, WOD_NEW_WINDOW]);
end;
procedure TfrmEpic7xParser.Chromium1BeforeResourceLoad(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const request: ICefRequest; const callback: ICefRequestCallback;
  out Result: TCefReturnValue);
begin
  if (request.ResourceType in [RT_IMAGE, RT_XHR, RT_SCRIPT, RT_FONT_RESOURCE]) then
    request.Method := 'HEAD';
  if (request.ResourceType in [RT_IMAGE]) then
    CefLog('BeforeResourceLoad', 1, CEF_LOG_SEVERITY_ERROR, request.Url);
end;

procedure TfrmEpic7xParser.Chromium1Close(Sender: TObject;
  const browser: ICefBrowser; var aAction : TCefCloseBrowserAction);
begin
  PostMessage(Handle, CEF_DESTROY, 0, 0);
  aAction := cbaDelay;
end;
procedure TfrmEpic7xParser.Chromium1ConsoleMessage(Sender: TObject;
  const browser: ICefBrowser; level: Cardinal; const message, source: ustring;
  line: Integer; out Result: Boolean);
begin
  // In this event we receive the message with the name and value of a DOM node
  // from the render process.
  // This event may receive many other messages but we identify our message
  // thanks to the preamble.
  // The we set MsgContents with the rest of the message and send a
  // MINIBROWSER_SHOWMESSAGE message to show MsgContents in the main thread safely.
  // This and many other TChromium events are executed in a CEF thread. The VCL
  // should be used only in the main thread and we use a message and a field
  // protected by a synchronization object to call showmessage safely.
  if (length(message) > 0) and
     (copy(message, 1, length(CONSOLE_MSG_PREAMBLE)) = CONSOLE_MSG_PREAMBLE) then
    begin
      MsgContents := copy(message, succ(length(CONSOLE_MSG_PREAMBLE)), length(message));
      if (length(MsgContents) = 0) then
        MsgContents := 'The INPUT node has no value'
       else
        MsgContents := 'INPUT node value : ' + quotedstr(MsgContents);
      PostMessage(Handle, MINIBROWSER_SHOWMESSAGE, 0, 0);
    end;
end;
procedure TfrmEpic7xParser.Chromium1ContextMenuCommand(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame;
  const params: ICefContextMenuParams; commandId: Integer;
  eventFlags: Cardinal; out Result: Boolean);
begin
  Result := False;
  case commandId of
    MINIBROWSER_CONTEXTMENU_VISITDOM_PARTIAL :
      PostMessage(Handle, MINIBROWSER_VISITDOM_PARTIAL, 0, 0);
    MINIBROWSER_CONTEXTMENU_VISITDOM_FULL :
      PostMessage(Handle, MINIBROWSER_VISITDOM_FULL, 0, 0);
    MINIBROWSER_CONTEXTMENU_VISITDOM_JS :
      PostMessage(Handle, MINIBROWSER_VISITDOM_JS, 0, 0);
    MINIBROWSER_CONTEXTMENU_COPYFRAMEIDS_1 :
      PostMessage(Handle, MINIBROWSER_COPYFRAMEIDS_1, 0, 0);
    MINIBROWSER_CONTEXTMENU_COPYFRAMEIDS_2 :
      PostMessage(Handle, MINIBROWSER_COPYFRAMEIDS_2, 0, 0);
    MINIBROWSER_CONTEXTMENU_SETINPUTVALUE_JS :
      frame.ExecuteJavaScript('document.getElementById("keywords").value = "qwerty";', 'about:blank', 0);
  end;
end;
procedure TfrmEpic7xParser.Chromium1DocumentAvailableInMainFrame(Sender: TObject;
  const browser: ICefBrowser);
begin
  if Assigned(browser) and Assigned(browser.MainFrame)  then
  begin
    btnParseHeroList.Enabled := True;
    btnParseHeroInfo.Enabled := True;
    Caption := browser.MainFrame.Url;
    FMainFrameLoading := True;
  end;
end;

procedure TfrmEpic7xParser.Chromium1ProcessMessageReceived(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage; out Result: Boolean);
//var
//  TempVisitor : TCefFastDomVisitor2;
begin
  Result := False;
  if (message = nil) or (message.ArgumentList = nil) then exit;
  // Message received from the DOMVISITOR in CEF
  if (message.Name = DOMVISITOR_MSGNAME_PARTIAL) then
    begin
      StatusText := 'DOM Visitor result text : ' + message.ArgumentList.GetString(0);
          if (frame <> nil) and frame.IsValid then
            begin
//              TempVisitor := TCefFastDomVisitor2.Create(browser, frame, DOMVisitor_OnDocAvailable);
//              frame.VisitDom(TempVisitor);
            end;
      Result := True;
    end
   else
    if (message.Name = DOMVISITOR_MSGNAME_FULL) then
      begin
        Clipboard.AsText := message.ArgumentList.GetString(0);
        StatusText := 'HTML copied to the clipboard';
        Result := True;
      end
     else
      if (message.Name = FRAMEIDS_MSGNAME) then
        begin
          Clipboard.AsText := message.ArgumentList.GetString(0);
          StatusText := 'Frame IDs copied to the clipboard in the render process.';
          Result := True;
        end;
  if Result then
    PostMessage(Handle, MINIBROWSER_SHOWSTATUSTEXT, 0, 0);
end;
procedure TfrmEpic7xParser.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := FCanClose;
  if not(FClosing) then
    begin
      FClosing := True;
      Visible  := False;
      Chromium1.CloseBrowser(True);
    end;
end;
procedure TfrmEpic7xParser.FormCreate(Sender: TObject);
begin
  FCanClose := False;
  FClosing  := False;
  FCritSection := TCriticalSection.Create;
  FWorkDone := TEvent.Create(nil, True, False, C_WORK_DONE);
  if FileExists('CEF4Delphi.log') then
    DeleteFile('CEF4Delphi.log');
end;
procedure TfrmEpic7xParser.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FCritSection);
  FWorkDone.Free;
end;
procedure TfrmEpic7xParser.FormShow(Sender: TObject);
begin
  ProgressBar1.Parent := StatusBar1;
  ProgressBar1.Align := alRight;
  ProgressBar1.Width := 300;
  ProgressBar1.BringToFront;
  // GlobalCEFApp.GlobalContextInitialized has to be TRUE before creating any browser
  // If it's not initialized yet, we use a simple timer to create the browser later.
  if not(Chromium1.CreateBrowser(CEFWindowParent1, '')) then Timer1.Enabled := True;
end;
procedure TfrmEpic7xParser.GoBtnClick(Sender: TObject);
begin
  btnParseHeroInfo.Enabled := False;
  btnParseHeroList.Enabled := False;
  Chromium1.LoadURL(AddressEdt.Text);
end;
procedure TfrmEpic7xParser.NavigateAndWait(const AUrl: string);
var
  st: Cardinal;
begin
  FMainFrameLoading := False;
  st := GetTickCount;
  CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== NavigateURL: ' + AUrl);
  Chromium1.LoadURL(AUrl);
  while not FMainFrameLoading do
  begin
    Application.HandleMessage;
    Application.DoApplicationIdle;
    Sleep(100);
  end;
  Sleep(100);
  CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== NavigateURL Complete: ' + IntToStr(GetTickCount - st));
end;

procedure TfrmEpic7xParser.BrowserCreatedMsg(var aMessage : TMessage);
begin
  CEFWindowParent1.UpdateSize;
  AddressBarPnl.Enabled := True;
  GoBtn.Click;
end;
procedure TfrmEpic7xParser.BrowserDestroyMsg(var aMessage : TMessage);
begin
  CEFWindowParent1.Free;
end;
procedure TfrmEpic7xParser.btnParseHeroListClick(Sender: TObject);
begin
  if (Sender is TWinControl) then
    (Sender as TWinControl).Enabled := False;
  try
    FWorkDone.ResetEvent;
//    NavigateAndWait('https://epic7x.com/tier-list/');
    Chromium1.SendProcessMessage(PID_RENDERER, TCefProcessMessageRef.New(DOMVISITOR_PARSE_LIST));
    while FWorkDone.WaitFor(100) <> wrSignaled do
    begin
      Application.ProcessMessages;
      Application.DoApplicationIdle;
    end;
  finally
    if (Sender is TWinControl) then
      (Sender as TWinControl).Enabled := True;
  end;
end;

procedure TfrmEpic7xParser.btnParseHeroInfoClick(Sender: TObject);
var
  Obj: ISuperObject;
  i: Integer;
  st: Cardinal;
begin
  if (Sender is TWinControl) then
    (Sender as TWinControl).Enabled := False;
  try
    st := GetTickCount;
    Obj := TSuperObject.ParseFile(ChangeFileExt(ParamStr(0), '.json'), True);
//    HeroEnum := Obj.GetEnumerator;
    try
      ProgressBar1.Max := Obj.AsArray.Length;
      ProgressBar1.Position := 0;
    CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== Hero count = ' + IntToStr(Obj.AsArray.Length));
      for I := 0 to Obj.AsArray.Length - 1 do
      begin
        ProgressBar1.StepBy(1);
      CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== Current: ' + Obj.AsArray[i].S['name']);
        if Obj.AsArray[i].S['Url'] <> '' then
        begin
    //  CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== NavigateURL: ' + HeroEnum.Current.S['Url']);
//          NavigateAndWait(Obj.AsArray[i].S['Url']);
          {$MESSAGE WARN 'отладка для набора сетов и артифактов'}
          NavigateAndWait('https://epic7x.com/character/ainos/');
          FWorkDone.ResetEvent;
          Chromium1.SendProcessMessage(PID_RENDERER, TCefProcessMessageRef.New(DOMVISITOR_PARSE_HEROSET));
          while FWorkDone.WaitFor(100) <> wrSignaled do
          begin
            Application.ProcessMessages;
            Application.DoApplicationIdle;
          end;
          Break;
        end;
      end;
    finally
  CefLog('CEF4Delphi.log', 1, CEF_LOG_SEVERITY_ERROR, '=========== End Of Work   : ' + IntToStr(GetTickCount - st));
    end;
  finally
    if (Sender is TWinControl) then
      (Sender as TWinControl).Enabled := True;
  end;
end;
procedure TfrmEpic7xParser.VisitDOMMsg(var aMessage : TMessage);
var
  TempMsg : ICefProcessMessage;
begin
  // Use the ArgumentList property if you need to pass some parameters.
  TempMsg := TCefProcessMessageRef.New(RETRIEVEDOM_MSGNAME_PARTIAL); // Same name than TCefCustomRenderProcessHandler.MessageName
  Chromium1.SendProcessMessage(PID_RENDERER, TempMsg);
end;
procedure TfrmEpic7xParser.VisitDOM2Msg(var aMessage : TMessage);
var
  TempMsg : ICefProcessMessage;
begin
  // Use the ArgumentList property if you need to pass some parameters.
  TempMsg := TCefProcessMessageRef.New(RETRIEVEDOM_MSGNAME_FULL); // Same name than TCefCustomRenderProcessHandler.MessageName
  Chromium1.SendProcessMessage(PID_RENDERER, TempMsg);
end;
procedure TfrmEpic7xParser.VisitDOM3Msg(var aMessage : TMessage);
var
  TempJSCode, TempMessage : string;
begin
  // Here we send the name and value of the element with the "console trick".
  // We execute "console.log" in JavaScript to send TempMessage with a
  // known preamble that will be used to identify the message in the
  // TChromium.OnConsoleMessage event.
  TempMessage := 'document.getElementById("' + NODE_ID + '").value';
  TempJSCode  := 'console.log("' + CONSOLE_MSG_PREAMBLE + '" + ' + TempMessage + ');';
  chromium1.ExecuteJavaScript(TempJSCode, 'about:blank');
end;
procedure TfrmEpic7xParser.CopyFrameIDs1(var aMessage : TMessage);
var
  i          : NativeUInt;
  TempCount  : NativeUInt;
  TempArray  : TCefFrameIdentifierArray;
  TempString : string;
begin
  TempCount := Chromium1.FrameCount;
  if Chromium1.GetFrameIdentifiers(TempCount, TempArray) then
    begin
      TempString := '';
      i          := 0;
      while (i < TempCount) do
        begin
          TempString := TempString + inttostr(TempArray[i]) + CRLF;
          inc(i);
        end;
      clipboard.AsText := TempString;
      ShowStatusText('Frame IDs copied to the clipboard in the browser process (' + inttostr(TempCount) + ')');
    end;
end;
procedure TfrmEpic7xParser.CopyFrameIDs2(var aMessage : TMessage);
var
  TempMsg : ICefProcessMessage;
begin
  TempMsg := TCefProcessMessageRef.New(FRAMEIDS_MSGNAME);
  Chromium1.SendProcessMessage(PID_RENDERER, TempMsg);
end;
procedure TfrmEpic7xParser.ShowMessageMsg(var aMessage : TMessage);
begin
  showmessage(MsgContents);
end;
procedure TfrmEpic7xParser.ShowStatusTextMsg(var aMessage : TMessage);
begin
  ShowStatusText(StatusText);
end;
procedure TfrmEpic7xParser.WMMove(var aMessage : TWMMove);
begin
  inherited;
  if (Chromium1 <> nil) then Chromium1.NotifyMoveOrResizeStarted;
end;
procedure TfrmEpic7xParser.WMMoving(var aMessage : TMessage);
begin
  inherited;
  if (Chromium1 <> nil) then Chromium1.NotifyMoveOrResizeStarted;
end;
procedure TfrmEpic7xParser.ShowStatusText(const aText : string);
begin
  StatusBar1.Panels[0].Text := aText;
end;
procedure TfrmEpic7xParser.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if not(Chromium1.CreateBrowser(CEFWindowParent1, '')) and not(Chromium1.Initialized) then
    Timer1.Enabled := True;
end;
function TfrmEpic7xParser.GetMsgContents : string;
begin
  Result := '';
  if (FCritSection <> nil) then
    try
      FCritSection.Acquire;
      Result := FMsgContents;
    finally
      FCritSection.Release;
    end;
end;
procedure TfrmEpic7xParser.SetMsgContents(const aValue : string);
begin
  if (FCritSection <> nil) then
    try
      FCritSection.Acquire;
      FMsgContents := aValue;
    finally
      FCritSection.Release;
    end;
end;
function TfrmEpic7xParser.GetStatusText : string;
begin
  Result := '';
  if (FCritSection <> nil) then
    try
      FCritSection.Acquire;
      Result := FStatusText;
    finally
      FCritSection.Release;
    end;
end;
procedure TfrmEpic7xParser.SetStatusText(const aValue : string);
begin
  if (FCritSection <> nil) then
    try
      FCritSection.Acquire;
      FStatusText := aValue;
    finally
      FCritSection.Release;
    end;
end;
end.
