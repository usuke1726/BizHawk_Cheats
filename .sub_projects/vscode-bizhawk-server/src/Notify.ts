
import * as vscode from 'vscode';

const Notify = (message: string, time: number = 2000) => {
    vscode.window.withProgress({
        location: vscode.ProgressLocation.Notification,
        title: message,
        cancellable: false,
    }, (progress, _token) => new Promise<void>(resolve => {
        setTimeout(() => {
            progress.report({ increment: 100 });
            resolve();
        }, time);
    }));
}

export default Notify;
