
import * as vscode from 'vscode';
import getConfig, { CompletionKeysType } from './config';

class ProviderBase{
    private id;
    private trigger;
    private pattern;
    private insertFunc;
    constructor(
        id: CompletionKeysType,
        trigger: string | ((char: string) => boolean) | null,
        pattern: string | RegExp | ((beforeText: string, afterText: string, wholeLine: string) => boolean),
        insert: ((line: number, character: number, wholeText: string[]) => void)
    ){
        this.id = id;
        this.trigger = trigger;
        this.pattern = pattern;
        this.insertFunc = insert;
    }
    public checkTrigger(lastChar: string): boolean{
        const trigger = this.trigger;
        if(trigger === null){
            return true;
        }else if(typeof trigger === "string"){
            return lastChar === trigger;
        }else{
            return trigger(lastChar);
        }
    }
    public test(beforeText: string, afterText: string, wholeLine: string): boolean{
        if(!getConfig().autoCompletion[this.id]) return false;
        switch(typeof this.pattern){
            case "function":
                return this.pattern(beforeText, afterText, wholeLine);
            case "string":
                return beforeText.endsWith(this.pattern);
            default:
                return this.pattern.test(beforeText);
        }
    }
    public insert(line: number, character: number, wholeText: string[]): void{
        this.insertFunc(line, character, wholeText);
    }
};

class LocalLikeProvider extends ProviderBase{
    static readonly SpecialAliases: ReadonlySet<string> = new Set(["loaco", "lcl"]);
    private n = 0;
    constructor(){
        super("local", " ",
            (beforeText, afterText) => {
                if(afterText.trim()) return false;
                const k = beforeText.trimStart().slice(0, -1);
                if(k === "local") return false;
                if(LocalLikeProvider.toBeCorrected(k)){
                    this.n = k.length
                    return true;
                }
                return false;
            },
            async (line, character) => {
                const editor = vscode.window.activeTextEditor
                if(!editor) return;
                await editor.edit(editBuilder => {
                    editBuilder.replace(new vscode.Range(
                        new vscode.Position(line, character - this.n),
                        new vscode.Position(line, character + 1)
                    ), "local ");
                });
                const pos = editor.selection.start;
                editor.selection = new vscode.Selection(pos, pos);
            }
        )
    }
    private static toBeCorrected(k: string){
        return this.isAnagramOfLocal(k) || this.SpecialAliases.has(k);
    }
    private static isAnagramOfLocal(k: string){
        return k.length === 5 && k[0] === "l" && [...k].sort().join("") === "acllo";
    }
}

class LocalFunctionLikeProvider extends ProviderBase{
    constructor(){
        super("local function", " ",
            (beforeText, afterText) => {
                if(afterText.trim()) return false;
                return beforeText.trimStart().slice(0, -1) === "lfl";
            },
            async (line, character) => {
                const editor = vscode.window.activeTextEditor
                if(!editor) return;
                await editor.edit(editBuilder => {
                    editBuilder.replace(new vscode.Range(
                        new vscode.Position(line, character - 3),
                        new vscode.Position(line, character + 1)
                    ), "local function ");
                });
                const pos = editor.selection.start;
                editor.selection = new vscode.Selection(pos, pos);
            }
        )
    }
}
class FunctionLikeProvider extends ProviderBase{
    static readonly SpecialAliases: ReadonlyArray<string> = ["funtion", "ff", "funfun"];
    static readonly AllowedSymbols: ReadonlySet<string> = new Set([" ", "(", "="]);
    private n = 0;
    constructor(){
        super("function", " ",
            (beforeText) => {
                if(beforeText.endsWith("function ")) return false;
                const t = beforeText.trimStart();
                if(FunctionLikeProvider.isAnagramOfFunction(t)){
                    this.n = 8;
                    return true;
                }
                const k = FunctionLikeProvider.SpecialAliases.find(s => FunctionLikeProvider.find(t, s))
                if(k){
                    this.n = k.length;
                    return true;
                }
                return false;
            },
            async (line, character) => {
                const editor = vscode.window.activeTextEditor
                if(!editor) return;
                await editor.edit(editBuilder => {
                    editBuilder.replace(new vscode.Range(
                        new vscode.Position(line, character - this.n),
                        new vscode.Position(line, character + 1)
                    ), "function");
                });
                const pos = editor.selection.start;
                editor.selection = new vscode.Selection(pos, pos);
            }
        )
    }
    private static find(beforeText: string, text: string){
        const l = text.length;
        const c = beforeText.at(-l - 2);
        if(c && !this.AllowedSymbols.has(c)) return false;
        return text === beforeText.slice(-l - 1, -1);
    }
    private static isAnagramOfFunction(beforeText: string){
        const c = beforeText.at(-10);
        if(c && !this.AllowedSymbols.has(c)) return false;
        const k = beforeText.slice(-9, -1);
        return k[0] === "f" && [...k].sort().join("") === "cfinnotu";
    }
}

const patterns: ProviderBase[] = [
    new LocalLikeProvider(),
    new FunctionLikeProvider(),
    new LocalFunctionLikeProvider(),
];

const inString = (beforeText: string) => {
    return /^[^"']*("[^"]*"|'[^']*')*("[^"]*|'[^']*)$/.test(beforeText);
};

const exec = (e: vscode.TextDocumentChangeEvent) => {
    const lastChange = e.contentChanges[e.contentChanges.length - 1];
    if(!lastChange) return;
    const lastChar = lastChange.text;

    if(patterns.every(p => !p.checkTrigger(lastChar))){
        return;
    }

    const range = lastChange.range;
    const line = range.start.line;
    const character = range.start.character;

    const wholeText = e.document.getText().split(/\r?\n/);
    const beforeText = wholeText[line].substring(0, character + 1);
    const afterText = wholeText[line].substring(character + 1);
    if(inString(beforeText)){
        return;
    }
    const matchedPattern = patterns.find(p => p.test(beforeText, afterText, wholeText[line]));
    if(matchedPattern){
        matchedPattern.insert(line, character, wholeText);
    }
};

const setCompletionProviders = (context: vscode.ExtensionContext) => {
    vscode.workspace.onDidChangeTextDocument(e => {
        if(e.document.languageId !== "lua") return;
        exec(e);
    });
};

export default setCompletionProviders;
