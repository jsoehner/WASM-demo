const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');

function createWindow() {
  // Create the browser window
  const mainWindow = new BrowserWindow({
    width: 1000,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false
    },
    icon: path.join(__dirname, 'icon.png'), // Add an icon if available
    title: 'WASM Agent Viewer'
  });

  // Load the viewer
  mainWindow.loadFile(path.join(__dirname, 'index.html'));

  // Remove menu bar in production
  if (process.env.NODE_ENV === 'production') {
    Menu.setApplicationMenu(null);
  }
}

// This method will be called when Electron has finished initialization
app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

// Quit when all windows are closed, except on macOS
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
