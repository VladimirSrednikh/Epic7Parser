// ************************************************************************
// ***************************** CEF4Delphi *******************************
// ************************************************************************
//
// CEF4Delphi is based on DCEF3 which uses CEF to embed a chromium-based
// browser in Delphi applications.
//
// The original license of DCEF3 still applies to CEF4Delphi.
//
// For more information about CEF4Delphi visit :
//         https://www.briskbard.com/index.php?lang=en&pageid=cef
//
//        Copyright � 2020 Salvador Diaz Fau. All rights reserved.
//
// ************************************************************************
// ************ vvvv Original license and comments below vvvv *************
// ************************************************************************
(*
 *                       Delphi Chromium Embedded 3
 *
 * Usage allowed under the restrictions of the Lesser GNU General Public License
 * or alternatively the restrictions of the Mozilla Public License 1.1
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * Unit owner : Henri Gourvest <hgourvest@gmail.com>
 * Web site   : http://www.progdigy.com
 * Repository : http://code.google.com/p/delphichromiumembedded/
 * Group      : http://groups.google.com/group/delphichromiumembedded
 *
 * Embarcadero Technologies, Inc is not permitted to use or redistribute
 * this source code without explicit permission.
 *
 *)

unit uDOMVisitor;

{$I cef.inc}

interface

uses
  {$IFDEF DELPHI16_UP}
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.SyncObjs, System.Classes, Vcl.Graphics, Vcl.Menus, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Types,
  Vcl.ComCtrls, Vcl.ClipBrd, System.UITypes,
  {$ELSE}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Menus, SyncObjs,
  Controls, Forms, Dialogs, StdCtrls, ExtCtrls, Types, ComCtrls, ClipBrd,
  {$ENDIF}
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
  DOMVISITOR_MSGNAME_PARSELIST = 'domvisitorparselist';

  NODE_ID = 'keywords';

type
  TDOMVisitorFrm = class(TForm)
    CEFWindowParent1: TCEFWindowParent;
    Chromium1: TChromium;
    AddressBarPnl: TPanel;
    AddressEdt: TEdit;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    Panel1: TPanel;
    GoBtn: TButton;
    VisitDOMBtn: TButton;

    procedure Timer1Timer(Sender: TObject);
    procedure GoBtnClick(Sender: TObject);
    procedure VisitDOMBtnClick(Sender: TObject);

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

  protected
    // Variables to control when can we destroy the form safely
    FCanClose : boolean;  // Set to True in TChromium.OnBeforeClose
    FClosing  : boolean;  // Set to True in the CloseQuery event.

    // Critical section and fields to show information received in CEF events safely.
    FCritSection : TCriticalSection;
    FMsgContents : string;
    FStatusText  : string;

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
  DOMVisitorFrm: TDOMVisitorFrm;

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
                CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'Head child element : ' + TempChild.Name);
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
            CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'Focused element name : ' + TempNode.Name);
            CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'Focused element inner text : ' + TempNode.ElementInnerText);
          end;
      end;
  except
    on e : exception do
      if CustomExceptionHandler('SimpleNodeSearch', e) then raise;
  end;
end;

procedure ParseHeroList(const aDocument: ICefDomDocument; const aFrame : ICefFrame);
var
  TempNode : ICefDomNode;
  TempJSCode, TempMessage : string;
//  attrs: TStringList;
  attrs: TStrings;
begin
  try
    if (aDocument <> nil) then
    begin
      TempNode := aDocument.GetElementById('app');
      if (TempNode <> nil) then
      begin
//        <div class="pure-u-1 mt-20">
//        TempNode := FindNodeByAttrEx(TempNode, 'div', 'class', 'pure-u-1 mt-20')
        TempNode := FindNodeByAttrEx(TempNode, 'table', '', '');
        if TempNode <> nil then
        begin
//          CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'ParseHeroList');
//          CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'TempNode.Name : ' + TempNode.Name);
//          CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'TempNode.ElementTagName : ' + TempNode.ElementTagName);
//          CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'TempNode.AsMarkup : ' + TempNode.AsMarkup);

//          attrs := TStringList.Create;
//          try
//            TempNode.GetElementAttributes(attrs);
//            CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'TempNode.GetElementAttributes : ' + attrs.Text);
//          finally
//            attrs.Free;
//          end;
          CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'GetCurrentProcessId : ' + IntToStr(GetCurrentProcessId));
          TempNode := FindNodeByAttrEx(TempNode, 'tbody', '', '');
          if TempNode <> nil then
          begin


          end
        end
//        else
//          TempMessage := 'table not found';
      end
//      else
//        TempMessage := 'GetElementById app not found';
    end
    else
      TempMessage := 'aDocument = nil';

//    MessageBox(0, PChar(TempMessage), '', 0);
//
//      TempNode := aDocument.GetFocusedNode;
//
//      if (TempNode <> nil) then
//        begin
//          CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'Focused element name : ' + TempNode.Name);
//          CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'Focused element inner text : ' + TempNode.ElementInnerText);
//        end;
//    end;
  except
    on e : exception do
      if CustomExceptionHandler('SimpleNodeSearch', e) then raise;
  end;
end;


procedure DOMVisitor_ParseList(const browser: ICefBrowser; const frame: ICefFrame; const document: ICefDomDocument);
var
  TempMessage : ICefProcessMessage;
begin
  // This function is called from a different process.
  // document is only valid inside this function.
  // As an example, this function only writes the document title to the 'debug.log' file.
  CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'document.Title : ' + document.Title);

  // Simple DOM iteration example
//  if false then
//    SimpleDOMIteration(document);

  // Simple DOM searches
//  if false then
//    SimpleNodeSearch(document, frame);
  ParseHeroList(document, frame);
  // Sending back some custom results to the browser process
  // Notice that the DOMVISITOR_MSGNAME_PARTIAL message name needs to be recognized in
  // Chromium1ProcessMessageReceived
  try
    TempMessage := TCefProcessMessageRef.New(DOMVISITOR_MSGNAME_PARTIAL);
    TempMessage.ArgumentList.SetString(0, 'document.Title : ' + document.Title);

    if (frame <> nil) and frame.IsValid then
      frame.SendProcessMessage(PID_BROWSER, TempMessage);
  finally
    TempMessage := nil;
  end;
end;

procedure DOMVisitor_OnDocAvailable(const browser: ICefBrowser; const frame: ICefFrame; const document: ICefDomDocument);
var
  TempMessage : ICefProcessMessage;
begin
  // This function is called from a different process.
  // document is only valid inside this function.
  // As an example, this function only writes the document title to the 'debug.log' file.
  CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'document.Title : ' + document.Title);

  if document.HasSelection then
    CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'document.SelectionAsText : ' + quotedstr(document.SelectionAsText))
   else
    CefLog('CEF4Delphi', 1, CEF_LOG_SEVERITY_ERROR, 'document.HasSelection : False');

  // Simple DOM iteration example
//  SimpleDOMIteration(document);

  // Simple DOM searches
  SimpleNodeSearch(document, frame);

  // Sending back some custom results to the browser process
  // Notice that the DOMVISITOR_MSGNAME_PARTIAL message name needs to be recognized in
  // Chromium1ProcessMessageReceived
  try
    TempMessage := TCefProcessMessageRef.New(DOMVISITOR_MSGNAME_PARTIAL);
    TempMessage.ArgumentList.SetString(0, 'document.Title : ' + document.Title);

    if (frame <> nil) and frame.IsValid then
      frame.SendProcessMessage(PID_BROWSER, TempMessage);
  finally
    TempMessage := nil;
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

procedure DOMVisitor_GetFrameIDs(const browser: ICefBrowser; const frame : ICefFrame);
var
  i          : NativeUInt;
  TempCount  : NativeUInt;
  TempArray  : TCefFrameIdentifierArray;
  TempString : string;
  TempMsg    : ICefProcessMessage;
begin
  TempCount := browser.FrameCount;

  if browser.GetFrameIdentifiers(TempCount, TempArray) then
    begin
      TempString := '';
      i          := 0;

      while (i < TempCount) do
        begin
          TempString := TempString + inttostr(TempArray[i]) + CRLF;
          inc(i);
        end;

      try
        TempMsg := TCefProcessMessageRef.New(FRAMEIDS_MSGNAME);
        TempMsg.ArgumentList.SetString(0, TempString);

        if (frame <> nil) and frame.IsValid then
          frame.SendProcessMessage(PID_BROWSER, TempMsg);
      finally
        TempMsg := nil;
      end;
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
      if (message.name = DOMVISITOR_MSGNAME_PARSELIST) then
        begin
          if (frame <> nil) and frame.IsValid then
            begin
              TempVisitor := TCefFastDomVisitor2.Create(browser, frame, DOMVisitor_ParseList);
              frame.VisitDom(TempVisitor);
            end;
          aHandled := True;
        end
       else
      if (message.name = RETRIEVEDOM_MSGNAME_PARTIAL) then
        begin
          if (frame <> nil) and frame.IsValid then
            begin
              TempVisitor := TCefFastDomVisitor2.Create(browser, frame, DOMVisitor_OnDocAvailable);
              frame.VisitDom(TempVisitor);
            end;

          aHandled := True;
        end
       else
        if (message.name = RETRIEVEDOM_MSGNAME_FULL) then
          begin
            if (frame <> nil) and frame.IsValid then
              begin
                TempVisitor := TCefFastDomVisitor2.Create(browser, frame, DOMVisitor_OnDocAvailableFullMarkup);
                frame.VisitDom(TempVisitor);
              end;

            aHandled := True;
          end
         else
          if (message.name = FRAMEIDS_MSGNAME) then
            begin
              DOMVisitor_GetFrameIDs(browser, frame);
              aHandled := True;
            end;
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

procedure TDOMVisitorFrm.Chromium1AfterCreated(Sender: TObject; const browser: ICefBrowser);
begin
  PostMessage(Handle, CEF_AFTERCREATED, 0, 0);
end;

procedure TDOMVisitorFrm.Chromium1BeforeClose(Sender: TObject;
  const browser: ICefBrowser);
begin
  FCanClose := True;
  PostMessage(Handle, WM_CLOSE, 0, 0);
end;

procedure TDOMVisitorFrm.Chromium1BeforeContextMenu(Sender: TObject;
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

procedure TDOMVisitorFrm.Chromium1BeforePopup(Sender: TObject;
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

procedure TDOMVisitorFrm.Chromium1Close(Sender: TObject;
  const browser: ICefBrowser; var aAction : TCefCloseBrowserAction);
begin
  PostMessage(Handle, CEF_DESTROY, 0, 0);
  aAction := cbaDelay;
end;

procedure TDOMVisitorFrm.Chromium1ConsoleMessage(Sender: TObject;
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

procedure TDOMVisitorFrm.Chromium1ContextMenuCommand(Sender: TObject;
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

procedure TDOMVisitorFrm.Chromium1DocumentAvailableInMainFrame(Sender: TObject;
  const browser: ICefBrowser);
begin
  if Assigned(browser) and Assigned(browser.MainFrame)  then
    OutputdebugString(PChar('DocumentAvailableInMainFrame ' + browser.MainFrame.Url))
  else
    OutputdebugString('DocumentAvailableInMainFrame EMPTY');
end;

procedure TDOMVisitorFrm.Chromium1ProcessMessageReceived(Sender: TObject;
  const browser: ICefBrowser; const frame: ICefFrame; sourceProcess: TCefProcessId;
  const message: ICefProcessMessage; out Result: Boolean);
var
  TempVisitor : TCefFastDomVisitor2;
begin
  Result := False;

  if (message = nil) or (message.ArgumentList = nil) then exit;

  // Message received from the DOMVISITOR in CEF

  if (message.Name = DOMVISITOR_MSGNAME_PARTIAL) then
    begin
      StatusText := 'DOM Visitor result text : ' + message.ArgumentList.GetString(0);
          if (frame <> nil) and frame.IsValid then
            begin
              TempVisitor := TCefFastDomVisitor2.Create(browser, frame, DOMVisitor_OnDocAvailable);
              frame.VisitDom(TempVisitor);

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

procedure TDOMVisitorFrm.FormCloseQuery(Sender: TObject;
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

procedure TDOMVisitorFrm.FormCreate(Sender: TObject);
begin
  FCanClose := False;
  FClosing  := False;

  FCritSection := TCriticalSection.Create;
end;

procedure TDOMVisitorFrm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FCritSection);
end;

procedure TDOMVisitorFrm.FormShow(Sender: TObject);
begin
  // GlobalCEFApp.GlobalContextInitialized has to be TRUE before creating any browser
  // If it's not initialized yet, we use a simple timer to create the browser later.
  if not(Chromium1.CreateBrowser(CEFWindowParent1, '')) then Timer1.Enabled := True;
end;

procedure TDOMVisitorFrm.GoBtnClick(Sender: TObject);
begin
  Chromium1.LoadURL(AddressEdt.Text);
end;

procedure TDOMVisitorFrm.BrowserCreatedMsg(var aMessage : TMessage);
begin
  CEFWindowParent1.UpdateSize;
  AddressBarPnl.Enabled := True;
  GoBtn.Click;
end;

procedure TDOMVisitorFrm.BrowserDestroyMsg(var aMessage : TMessage);
begin
  CEFWindowParent1.Free;
end;

procedure TDOMVisitorFrm.VisitDOMBtnClick(Sender: TObject);
var
  TempMsg : ICefProcessMessage;
begin
//  PostMessage(Handle, MINIBROWSER_VISITDOM_PARTIAL, 0, 0);
  // Use the ArgumentList property if you need to pass some parameters.
  TempMsg := TCefProcessMessageRef.New(DOMVISITOR_MSGNAME_PARSELIST); // Same name than TCefCustomRenderProcessHandler.MessageName
  Chromium1.SendProcessMessage(PID_RENDERER, TempMsg);
end;

procedure TDOMVisitorFrm.VisitDOMMsg(var aMessage : TMessage);
var
  TempMsg : ICefProcessMessage;
begin
  // Use the ArgumentList property if you need to pass some parameters.
  TempMsg := TCefProcessMessageRef.New(RETRIEVEDOM_MSGNAME_PARTIAL); // Same name than TCefCustomRenderProcessHandler.MessageName
  Chromium1.SendProcessMessage(PID_RENDERER, TempMsg);
end;

procedure TDOMVisitorFrm.VisitDOM2Msg(var aMessage : TMessage);
var
  TempMsg : ICefProcessMessage;
begin
  // Use the ArgumentList property if you need to pass some parameters.
  TempMsg := TCefProcessMessageRef.New(RETRIEVEDOM_MSGNAME_FULL); // Same name than TCefCustomRenderProcessHandler.MessageName
  Chromium1.SendProcessMessage(PID_RENDERER, TempMsg);
end;

procedure TDOMVisitorFrm.VisitDOM3Msg(var aMessage : TMessage);
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

procedure TDOMVisitorFrm.CopyFrameIDs1(var aMessage : TMessage);
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

procedure TDOMVisitorFrm.CopyFrameIDs2(var aMessage : TMessage);
var
  TempMsg : ICefProcessMessage;
begin
  TempMsg := TCefProcessMessageRef.New(FRAMEIDS_MSGNAME);
  Chromium1.SendProcessMessage(PID_RENDERER, TempMsg);
end;

procedure TDOMVisitorFrm.ShowMessageMsg(var aMessage : TMessage);
begin
  showmessage(MsgContents);
end;

procedure TDOMVisitorFrm.ShowStatusTextMsg(var aMessage : TMessage);
begin
  ShowStatusText(StatusText);
end;

procedure TDOMVisitorFrm.WMMove(var aMessage : TWMMove);
begin
  inherited;

  if (Chromium1 <> nil) then Chromium1.NotifyMoveOrResizeStarted;
end;

procedure TDOMVisitorFrm.WMMoving(var aMessage : TMessage);
begin
  inherited;

  if (Chromium1 <> nil) then Chromium1.NotifyMoveOrResizeStarted;
end;

procedure TDOMVisitorFrm.ShowStatusText(const aText : string);
begin
  StatusBar1.Panels[0].Text := aText;
end;

procedure TDOMVisitorFrm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  if not(Chromium1.CreateBrowser(CEFWindowParent1, '')) and not(Chromium1.Initialized) then
    Timer1.Enabled := True;
end;

function TDOMVisitorFrm.GetMsgContents : string;
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

procedure TDOMVisitorFrm.SetMsgContents(const aValue : string);
begin
  if (FCritSection <> nil) then
    try
      FCritSection.Acquire;
      FMsgContents := aValue;
    finally
      FCritSection.Release;
    end;
end;

function TDOMVisitorFrm.GetStatusText : string;
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

procedure TDOMVisitorFrm.SetStatusText(const aValue : string);
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
