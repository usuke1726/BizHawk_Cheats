
import * as vscode from 'vscode';
import * as net from 'node:net';
import getConfig from './config';
import LogObject from './Log';
const { Log, Output } = LogObject.bind("Server");

let server: net.Server | null = null;
let socket: net.Socket | null = null;
let intervalId: NodeJS.Timeout | null = null;

const bar_id = "IBizHawk_status_bar";
let statusBarReservedMessage: string = "";
let statusBar: vscode.StatusBarItem = null!;
const warningBackground = new vscode.ThemeColor("statusBarItem.warningBackground")
const ensureStatusBarReady = () => {
    const was_null = !statusBar;
    statusBar ??= vscode.window.createStatusBarItem(bar_id, vscode.StatusBarAlignment.Right, 1000);
    if(was_null){
        statusBar.command = "extension.BizHawkServer.toggleActivity";
    }
    return was_null;
}
const inactive_message = () => "BizHawk inactive";
const createServer = () => {
    Log("createServer called");
    const { port } = getConfig();
    server = net.createServer(sock => {
        if(socket){
            Output("already connecting");
            sock.destroy();
        }
        socket = sock;
        sock.on("close", () => {
            Output("socket closed");
            socket = null;
            if(intervalId) clearInterval(intervalId);
            intervalId = null;
        });
        sock.on("error", e => {
            Output("ERROR:", e);
        })
        sock.on("data", data => {
            Log("received: ", data, "(現在はすべて破棄)");
        });
        intervalId = setInterval(() => {
            sock.write("0 ");
        }, 1000);
    });
    server.on("error", e => {
        Output("ERROR:", e);
    })
    server.listen(port);
    const mes = `BizHawk on port ${port}`;
    if(statusBar){
        statusBar.text = mes;
        statusBar.backgroundColor = undefined;
    }else statusBarReservedMessage = mes;
}
export const isServerActive = (): boolean => !!server;
export const hideStatusBar = () => statusBar?.hide();
export const showStatusBar = () => {
    if(ensureStatusBarReady()){
        statusBar.text = inactive_message();
    }
    statusBar.backgroundColor = isServerActive() ? undefined : warningBackground;
    if(statusBarReservedMessage) statusBar.text = statusBarReservedMessage;
    statusBar.show();
    statusBarReservedMessage = "";
}

export const ensureServerReady = () => {
    if(isServerActive()) return;
    createServer();
};

export const closeServer = () => {
    Log("closeServer called");
    if(server === null) return;
    if(socket){
        try{
            socket.destroy();
        }catch{}
        socket = null;
    }
    server.close();
    server = null;
    if(statusBar){
        statusBar.text = inactive_message();
        statusBar.backgroundColor = warningBackground;
    }
}
export const restartServer = () => {
    closeServer();
    createServer();
}

export const send = (mes: string) => {
    if(socket == null){
        throw "まだコネクションが確立していません。";
    }
    socket.write(`${mes.length} ${mes}`);
}

export const toggleActivity = () => {
    Log("toggleActivity called");
    if(isServerActive()){
        closeServer();
        if(!statusBar) vscode.window.showInformationMessage("IBizHawkサーバーが閉じられました");
    }else{
        ensureServerReady();
        if(!statusBar) vscode.window.showInformationMessage("IBizHawkサーバーが起動しました");
    }
}

export const setServerProviders = (context: vscode.ExtensionContext) => {
    vscode.workspace.onDidChangeConfiguration(e => {
        if(!e.affectsConfiguration("BizHawkServer.port")) return;
        if(isServerActive()){
            Output("port changed: server restarted");
            setTimeout(restartServer, 100);
        }
    });
    context.subscriptions.push(vscode.commands.registerCommand("extension.BizHawkServer.toggleActivity", toggleActivity));
};
