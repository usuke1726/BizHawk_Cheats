
import * as vscode from 'vscode';
import LogObject from './Log';
import { ensureServerReady, hideStatusBar, send as sendToClient, showStatusBar } from './Server';
import Notify from './Notify';
import { formatCode, isILua, onIBizHawkFileClosed, onFileFocusChanged } from './File';
const { Log, Output } = LogObject.bind("Sender");


const send = () => {
    const editor = vscode.window.activeTextEditor;
    if(!editor || !isILua(editor.document)){
        return;
    }
    Log("EXECUTE");
    let resolver: (() => void) | null = null;
    Notify("実行中...", 500);
    sendToClient(formatCode(editor.document.getText()));
}

const checkILuaOpenedAtActivating = () => {
    const editor = vscode.window.activeTextEditor;
    if(!editor || !isILua(editor.document)) return;
    Output("ILua opened when activating");
    onFileFocusChanged();
}

const setSenderProviders = (context: vscode.ExtensionContext) => {
    Log("sender activated");
    context.subscriptions.push(vscode.commands.registerCommand("extension.BizHawkServer.send", send));
    vscode.window.onDidChangeActiveTextEditor(e => {
        onFileFocusChanged();
    });
    vscode.workspace.onDidCloseTextDocument(e => {
        if(isILua(e)) onIBizHawkFileClosed();
    });
    setTimeout(checkILuaOpenedAtActivating, 500);
}

export default setSenderProviders;
