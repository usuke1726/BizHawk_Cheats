
import * as vscode from 'vscode';
import LogObject from './Log';
import { formatCode, Notebook_ID as ID, onIBizHawkFileClosed, onFileFocusChanged, STOP_PREFIX } from './File';
import { ensureServerReady, isServerActive, send as sendToClient } from './Server';
import Notify from './Notify';
import { createTamplte } from './NotebookTemplate';
import getConfig from './config';
const { Log, Output } = LogObject.bind("Notebook");


type RowNotebookCell = {
    language: string;
    value: string;
    kind: vscode.NotebookCellKind;
};
const isNoteBookCellKind = (obj: any): obj is vscode.NotebookCellKind => {
    return obj === 1 || obj === 2;
};
const isRowNotebookCell = (obj: any): obj is RowNotebookCell => {
    return (
        typeof obj === "object" &&
        obj.hasOwnProperty("language") && typeof obj.language === "string" &&
        ["lua", "markdown"].includes(obj.language) &&
        obj.hasOwnProperty("value") && typeof obj.value === "string" &&
        ["string", "undefined"].includes(typeof obj.outputs) &&
        obj.hasOwnProperty("kind") && isNoteBookCellKind(obj.kind)
    );
};
const isRowNotebookCellArray = (obj: any): obj is RowNotebookCell[] => {
    return (
        Array.isArray(obj) &&
        obj.every(el => isRowNotebookCell(el))
    );
};

class Serializer implements vscode.NotebookSerializer{
    async deserializeNotebook(content: Uint8Array): Promise<vscode.NotebookData> {
        try{
            const text = (new TextDecoder()).decode(content);
            if(!text.trim()) return new vscode.NotebookData([]);
            const data = JSON.parse(text);
            if(!isRowNotebookCellArray(data)) throw "invalid data";
            return new vscode.NotebookData(data.map(item => {
                const data = new vscode.NotebookCellData(item.kind, item.value, item.language);
                data.outputs = [];
                return data;
            }));
        }catch(e){
            Output("IBizHawk deserialization error", e);
            throw new vscode.LanguageModelError("無効な IBizHawk ファイルです")
        }
    }
    async serializeNotebook(data: vscode.NotebookData): Promise<Uint8Array> {
        const contents = data.cells.map((cell): RowNotebookCell => {
            return {
                kind: cell.kind,
                language: cell.languageId,
                value: cell.value
            };
        })
        return (new TextEncoder()).encode(JSON.stringify(contents));
    }
}

class Controller{
    private readonly id: string = "ibizhawk-notebook-controller";
    private readonly type: string = ID;
    private readonly controller: vscode.NotebookController;
    private readonly label = "IBizHawk Notebook";
    constructor(){
        this.controller = vscode.notebooks.createNotebookController(this.id, this.type, this.label)
        this.controller.supportedLanguages = ["lua"];
        this.controller.executeHandler = this.execute.bind(this);
    }
    async execute(cells: vscode.NotebookCell[], notebook: vscode.NotebookDocument, controller: vscode.NotebookController){
        Log("EXECUTE");
        const cell = cells.length > 1 ? cells[cells.length - 1] : cells[0];
        const exe = controller.createNotebookCellExecution(cell);
        const code = formatCode(cell.document.getText());
        ensureServerReady();
        exe.start(Date.now());
        if(!isServerActive()){
            exe.appendOutput(new vscode.NotebookCellOutput([
                vscode.NotebookCellOutputItem.text("IBizHawkサーバが起動できていません")
            ]));
            exe.end(false);
            return;
        }
        try{
            sendToClient(code);
            exe.end(true)
        }catch(e){
            const mes = (e instanceof Error) ? e.message : String(e);
            exe.appendOutput(new vscode.NotebookCellOutput([
                vscode.NotebookCellOutputItem.text(mes)
            ]));
            exe.end(false);
        }
    }
}
const controller: Controller = new Controller();

const open = async () => {
    Log("Notebook open");
    const initialContents: vscode.NotebookCellData[] = await createTamplte();
    const notebookData = initialContents.length 
        ? new vscode.NotebookData(initialContents)
        : new vscode.NotebookData([
            new vscode.NotebookCellData(vscode.NotebookCellKind.Code, "", "lua")
        ]);
    Log(notebookData);
    const notebook = await vscode.workspace.openNotebookDocument(ID, notebookData);
    vscode.window.showNotebookDocument(notebook);
};

const insertTemplate = async () => {
    const editor = vscode.window.activeNotebookEditor;
    if(!editor){
        vscode.window.showErrorMessage("ノートブックがアクティブでありません");
        return;
    }
    const initialContents: vscode.NotebookCellData[] = await createTamplte();
    if(initialContents.length === 0){
        vscode.window.showWarningMessage("テンプレートが空です。");
        return;
    }
    const edit = new vscode.WorkspaceEdit();
    edit.set(editor.notebook.uri, [
        vscode.NotebookEdit.insertCells(0, initialContents)
    ])
    vscode.workspace.applyEdit(edit);
};

let stopCommandCache: string | null = null;
const loadStopCommand = () => {
    const command = getConfig().stopCommand;
    const str = typeof command === "string" ? command : command.join("\n");
    if(str.length < 10 && ["RST:", "STOP:", "ST:"].includes(str.trim().toUpperCase())){
        stopCommandCache = STOP_PREFIX;
    }else{
        stopCommandCache = formatCode(str);
    }
    Log(`Loaded Stop Command:\n${stopCommandCache}`);
    return stopCommandCache;
}
const getStopCommand = () => stopCommandCache ??= loadStopCommand();

const sendStopCommand = () => {
    ensureServerReady();
    if(!isServerActive()){
        vscode.window.showErrorMessage("IBizHawkサーバが起動できていません");
        return
    }
    try{
        sendToClient(getStopCommand());
    }catch(e){
        const mes = (e instanceof Error) ? e.message : String(e);
        vscode.window.showErrorMessage(`ストップコマンドの送信に失敗しました:\n${mes}`);
    }
}

const setNotebookProviders = (context: vscode.ExtensionContext) => {
    Log("Notebook activated");
    context.subscriptions.push(vscode.workspace.registerNotebookSerializer(ID, new Serializer()));
    context.subscriptions.push(vscode.commands.registerCommand("extension.BizHawkNotebook.createNewIBizHawkNotebook", open));
    context.subscriptions.push(vscode.commands.registerCommand("extension.BizHawkNotebook.insertNotebookTemplateOnTop", insertTemplate));
    context.subscriptions.push(vscode.commands.registerCommand("extension.BizHawkServer.stop", sendStopCommand));
    vscode.workspace.onDidChangeConfiguration(e => {
        if(e.affectsConfiguration("BizHawkServer.stopCommand")){
            stopCommandCache = null;
            setTimeout(loadStopCommand, 200);
        }
    });
    vscode.window.onDidChangeActiveNotebookEditor(e => {
        onFileFocusChanged();
    });
    vscode.workspace.onDidCloseNotebookDocument(e => {
        if(e.notebookType !== ID) return;
        onIBizHawkFileClosed();
    });
};

export default setNotebookProviders;
