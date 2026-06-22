
import * as vscode from 'vscode';
import LogObject from './Log';
import getConfig, { isStringArray } from './config';
import path from "node:path";
import fs from "node:fs/promises";
const { Log, Output } = LogObject.bind("NotebookTemplates");

const filePrefix = "file:";

const getExt = (p: string) => p.slice(p.lastIndexOf(".")).toLowerCase();

const isValidExt = (p: string) => [".txt", ".lua"].includes(getExt(p));

const existsFile = async (p: string) => {
    try{
        return (await fs.lstat(p)).isFile()
    }catch{return false;}
}

const findPath = async (query: string): Promise<string> => {
    if(!isValidExt(query)){
        throw `ファイルは .txt あるいは .lua でなければなりません\n(${query})`;
    }
    const folders = vscode.workspace.workspaceFolders;
    if(!folders){
        if(await existsFile(query)) return query;
        throw `ファイルが見つかりません\n(${query})`;
    }
    for(const f of folders){
        const p = path.resolve(f.uri.fsPath, query);
        if(await existsFile(p)) return p;
    }
    throw `ファイルが見つかりません\n(${query})`;
}

const parseText = async (value: string | string[]): Promise<string | null> => {
    if(isStringArray(value)){
        return (await (Promise.all(value.map(parseText)))).filter(s => s !== null).join("\n\n");
    }
    value = value.replaceAll("\r", "");
    if(value.substring(0, filePrefix.length).toLowerCase() !== filePrefix) return value;
    const query = value.substring(5).trimStart().split("\n", 1)[0].trimEnd();
    try{
        const p = await findPath(query)
        const contents = await fs.readFile(p, "utf-8");
        Log(`loaded file ${p}`);
        return contents.replaceAll("\r", "").trim();
    }catch(e){
        const err = e instanceof Error ? e.message : String(e);
        const mes = `エラー: ${err}`;
        Output(mes);
        vscode.window.showErrorMessage(mes);
        return null;
    }
}

export const createTamplte = async (): Promise<vscode.NotebookCellData[]> => {
    try{
        return (await Promise.all(getConfig().IBizNotebookTemplates
            .map(async temp => {
                if(typeof temp === "string" || isStringArray(temp)){
                    return { code: true, value: await parseText(temp) };
                }
                return { code: temp.kind === "code", value: await parseText(temp.value) };
            }))
        )
        .filter(obj => obj.value !== null)
        .map(obj => obj.code
            ? new vscode.NotebookCellData(vscode.NotebookCellKind.Code, obj.value!, "lua")
            : new vscode.NotebookCellData(vscode.NotebookCellKind.Markup, obj.value!, "markdown")
        )
    }catch(e){
        Output(`ERROR: ${e instanceof Error ? e.message : String(e)}`);
        return [];
    }
}
