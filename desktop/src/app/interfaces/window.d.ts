interface Electron {
    getDarkTheme: () => Promise<boolean>;
    setDarkTheme: (value: 'system' | 'light' | 'dark') => Promise<void>;
}

// eslint-disable-next-line no-unused-vars
interface Window {
    electron?: Electron;
}
