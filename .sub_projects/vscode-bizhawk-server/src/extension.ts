
import * as vscode from 'vscode';
import setNotebookProviders from './Notebook';
import { closeServer, setServerProviders } from './Server';
import setSenderProviders from './Sender';
import LogObject from './Log';
const { Log, Output } = LogObject.bind("extension");

export function activate(context: vscode.ExtensionContext){
    try{
        setNotebookProviders(context);
        setSenderProviders(context);
        setServerProviders(context);
        Output("extension successfully activated");
    }catch(e){
        const mes = `DeSmuME Server couldn't start ${String(e)}`;
        vscode.window.showErrorMessage(mes);
    }
}

export function deactivate(){
    closeServer();
}
