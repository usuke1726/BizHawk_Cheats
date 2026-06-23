
import * as vscode from 'vscode';
import LogObject from './Log';
const { Log, Output } = LogObject.bind("Config");

export const isStringArray = (obj: any): obj is string[] => Array.isArray(obj) && obj.every(o => typeof o === "string");
export type NotebookTemplateObj = {
    kind: "code" | "markup",
    value: string | string[],
};
const isNotebookTemplateObj = (obj: any): obj is NotebookTemplateObj => {
    if(typeof obj !== "object") return false;
    return (
        obj.hasOwnProperty("kind") && ["code", "markup"].includes(obj["kind"]) &&
        obj.hasOwnProperty("value") && (typeof obj["value"] === "string" || isStringArray(obj["value"]))
    );
}
export type NotebookTemplates = (string | string[] | NotebookTemplateObj)[]
const isNotebookTemplates = (obj: any): obj is NotebookTemplates => {
    if(!Array.isArray(obj)) return false;
    return obj.every(o => typeof o === "string" || isStringArray(o) || isNotebookTemplateObj(o));
}

type Config = {
    port: number,
    stopCommand: string | string[],
    IBizNotebookTemplates: NotebookTemplates,
    alwaysShowStatus: boolean,
    autoListen: boolean,
    autoClose: boolean,
}
const defaultConfig: Config = {
    port: 8099,
    stopCommand: "",
    IBizNotebookTemplates: [],
    alwaysShowStatus: false,
    autoListen: false,
    autoClose: true,
}
type ConfigKey = keyof Config;
const conditions: {[key in ConfigKey]: (val: unknown) => boolean} = {
    port: val => typeof val === "number",
    stopCommand: val => typeof val === "string" || isStringArray(val),
    IBizNotebookTemplates: val => isNotebookTemplates(val),
    alwaysShowStatus: val => typeof val === "boolean",
    autoListen: val => typeof val === "boolean",
    autoClose: val => typeof val === "boolean",
}
const keys: ConfigKey[] = Object.keys(conditions) as ConfigKey[];
const isConfig = (obj: any): obj is Config => {
    return (
        typeof obj === "object" &&
        keys.every(k => obj.hasOwnProperty(k) && conditions[k](obj[k]))
    );
}
let configCache: Config | undefined = undefined;
let initted = false;
const loadConfig = (): Config => {
    const config = vscode.workspace.getConfiguration("BizHawkServer");
    const obj = Object.fromEntries(keys.map(k => [k, config.get<any>(k)]));
    if(isConfig(obj)){
        configCache = obj;
        Output(`successfully ${initted ? "re" : ""}loaded config.`);
        Log("config:", configCache);
    }else{
        Log("FAILED LOADING CONFIG");
        Output(`FAILED LOADING CONFIG (will use default values)\n\tvalue: ${JSON.stringify(obj)}`);
        configCache = defaultConfig;
    }
    if(!initted){
        initted = true;
        vscode.workspace.onDidChangeConfiguration(e => {
            configCache = undefined;
            loadConfig();
        });
    }
    return configCache;
}
const getConfig = (): Config => {
    return configCache ?? loadConfig();
};

export default getConfig;
