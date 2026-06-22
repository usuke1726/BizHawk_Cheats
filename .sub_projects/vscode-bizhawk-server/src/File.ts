
import * as vscode from 'vscode';
import getConfig from './config';
import { closeServer, ensureServerReady, hideStatusBar, isServerActive, showStatusBar } from './Server';
import Notify from './Notify';
import LogObject from './Log';
const { Log, Output } = LogObject.bind("File");

export const Notebook_ID = "bizhawk-server-notebook";
const EXECUTE_PREFIX = "do:"

const getExt = (filename: string) => filename.slice(filename.lastIndexOf(".")).toLowerCase();
const isILuaExt = (filename: string) => getExt(filename) === ".ilua";
const isIBizNotebookExt = (filename: string) => getExt(filename) === ".ibiz";
export const isILua = (file: string | vscode.TextDocument) => {
    if(typeof(file) === "string") return isILuaExt(file);
    if(file.uri.scheme === "vscode-notebook-cell"){
        return file.languageId === "lua" && isIBizNotebookExt(file.fileName);
    }
    return file.languageId === "lua" && isILuaExt(file.fileName);
}

const existsOpenedIBizHawkNotebook = () => {
    return vscode.workspace.notebookDocuments.some(n => n.notebookType === Notebook_ID);
}
const existsOpenedILuaFile = () => {
    return vscode.workspace.textDocuments.some(isILua);
}
export const existsOpenedIBizHawkFile = () => existsOpenedILuaFile() || existsOpenedIBizHawkNotebook();

export const formatCode = (code: string): string => {
    return EXECUTE_PREFIX + code.replaceAll("\r", "")
    .trim().split("\n")
    .map(line => line.trimStart())
    .filter(line => {
        if(!line.length) return false;
        // 行頭の行コメントのみ削除、それ以外はそのまま送り付ける
        if(line.startsWith("--") && !line.startsWith("--[[")) return false;
        return true;
    })
    .join("\n");
}

const isIBizFileFocused = () => {
    const editor = vscode.window.activeTextEditor;
    if(editor) return isILua(editor.document);
    const notebook = vscode.window.activeNotebookEditor;
    if(notebook) return notebook.notebook.notebookType === Notebook_ID;
    return false;
}

export const onFileFocusChanged = () => {
    const config = getConfig();
    if(isIBizFileFocused()){
        if(config.autoListen){
            ensureServerReady();
        }
        showStatusBar();
    }else{
        if(!config.alwaysShowStatus) hideStatusBar();
    }
}

export const onIBizHawkFileClosed = () => {
    const config = getConfig();
    if(config.autoClose && !existsOpenedIBizHawkFile()){
        const wasServerActive = isServerActive();
        hideStatusBar();
        closeServer();
        if(wasServerActive){
            Notify("すべてのIBizHawkファイルが閉じられたので、サーバを停止しました。", 2000);
        }
    }
}
