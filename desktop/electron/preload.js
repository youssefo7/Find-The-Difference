const { contextBridge, ipcRenderer } = require('electron/renderer');

contextBridge.exposeInMainWorld('electron', {
    getDarkTheme: () => ipcRenderer.invoke('dark-mode:get'),
    setDarkTheme: (value) => ipcRenderer.invoke('dark-mode:set', value),
});
