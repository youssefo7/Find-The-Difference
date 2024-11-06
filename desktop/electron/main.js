const { app, BrowserWindow, ipcMain, nativeTheme } = require('electron');
const path = require('node:path');

const createWindow = () => {
    const appWindow = new BrowserWindow({
        width: 1000,
        height: 800,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            nodeIntegration: true,
        },
    });

    const isFrench = app.getLocale().startsWith('fr');
    const language = isFrench ? 'fr' : 'en';

    // Electron Build Path
    const url = `file://${__dirname}/../dist/client/${language}/index.html`;
    appWindow.loadURL(url);

    appWindow.setMenuBarVisibility(false);

    // Initialize the DevTools.
    // appWindow.webContents.openDevTools();

    appWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription, validatedURL) => {
        console.log('did-fail-load');
        console.log({ errorCode, errorDescription, validatedURL });
        const arr = validatedURL.split('/');
        const language = arr[arr.length - 1] === 'fr' ? 'fr' : 'en';

        const url = `file://${__dirname}/../dist/client/${language}/index.html`;
        appWindow.loadURL(url);
    });
};

ipcMain.handle('dark-mode:get', () => {
    return nativeTheme.shouldUseDarkColors;
});

ipcMain.handle('dark-mode:set', (event, value) => {
    nativeTheme.themeSource = value;
});

app.whenReady().then(() => {
    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});
