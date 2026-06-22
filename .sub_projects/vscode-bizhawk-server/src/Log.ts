
import * as vscode from 'vscode';

class Log{
    private static readonly isDebug: boolean = true;
    private static outputChannel = vscode.window.createOutputChannel("IBizHawk Server");
    static line(tag: string, ...messages: any[]): string{
        return `${this.getDate()} [${tag}] ${messages.map(m => String(m)).join(" ")}`;
    }
    private static _isDebug(){ return process.env.NODE_ENV !== "production" && this.isDebug; }
    private static _log(mes: string){
        if(this._isDebug()){
            console.log(mes);
        }
    }
    static log(tag: string, ...messages: any[]){ this._log(this.line(tag, ...messages)); }
    static output(tag: string, ...messages: any[]){
        const line = this.line(tag, ...messages);
        this._log(line);
        this.outputChannel.appendLine(line);
    }
    private static getDate(){
        const d = new Date();
        return `${d.toLocaleString("sv-SE")}.${d.getMilliseconds().toString().padStart(3, "0")}`;
    }
    static bind(tag: string){
        return {
            Log: (...messages: any[]) => this.log(tag, ...messages),
            Output: (...messages: any[]) => this.output(tag, ...messages)
        };
    }
}

export default Log;
