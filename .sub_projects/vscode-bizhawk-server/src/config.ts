
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

export const CompletionKeys = ["local", "function", "local function"] as const;
export type CompletionKeysType = typeof CompletionKeys[number];
export type CompletionTypes = {
    [key in CompletionKeysType]: boolean;
};
type UserDefinedCompletionTypes = boolean | {
    [key in CompletionKeysType]?: boolean;
};
const isUserDefinedCompletionTypes = (obj: any): obj is UserDefinedCompletionTypes => {
    return (typeof obj === "boolean") || (
        typeof obj === "object" &&
        CompletionKeys.every(k => !obj.hasOwnProperty(k) || typeof obj[k] === "boolean")
    );
};
const formatCompletionTypes = (types: UserDefinedCompletionTypes): CompletionTypes => {
    if(typeof types === "boolean"){
        return Object.fromEntries(CompletionKeys.map(k => [k, types])) as CompletionTypes
    }
    return {
        ...defaultConfig.autoCompletion,
        ...types
    };
};

type Config = {
    port: number,
    stopCommand: string | string[],
    IBizNotebookTemplates: NotebookTemplates,
    alwaysShowStatus: boolean,
    autoListen: boolean,
    autoClose: boolean,
    autoCompletion: CompletionTypes,
}
const defaultConfig: Config = {
    port: 8099,
    stopCommand: "",
    IBizNotebookTemplates: [],
    alwaysShowStatus: false,
    autoListen: false,
    autoClose: true,
    autoCompletion: Object.fromEntries(CompletionKeys.map(k => [k, true])) as CompletionTypes,
}
type ConfigKey = keyof Config;
const conditions: {[key in ConfigKey]: (val: unknown) => boolean} = {
    port: val => typeof val === "number",
    stopCommand: val => typeof val === "string" || isStringArray(val),
    IBizNotebookTemplates: val => isNotebookTemplates(val),
    alwaysShowStatus: val => typeof val === "boolean",
    autoListen: val => typeof val === "boolean",
    autoClose: val => typeof val === "boolean",
    autoCompletion: val => isUserDefinedCompletionTypes(val),
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
        obj.autoCompletion = formatCompletionTypes(obj.autoCompletion);
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
