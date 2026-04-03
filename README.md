# BeepBridge

Cross-platform desktop server that receives barcode scans over HTTP and types them into the focused application.

## Quick start

```bash
cd server
pip install -r requirements.txt
python main.py
```

The server starts on port **8080** by default. Change it from the settings window (right-click the tray icon → *Open settings*).

## API

### POST /scan

```json
{ "barcode": "1234567890" }
```

The server types the barcode value into the currently focused window, followed by the configured key sequence (default: Enter).

### GET /health

Returns `{ "status": "running" }`.

## Building a standalone executable

```bash
cd server
pip install -r requirements.txt
pyinstaller build.spec
```

The output goes to `server/dist/BeepBridge/`.

## macOS note

`pynput` requires accessibility permissions. Go to **System Settings → Privacy & Security → Accessibility** and grant permission to the terminal or the built app.

## Configuration

- **server/config.json** – server port
- **server/keys.json** – key sequence sent after each barcode (array of `{"key": "..."}` or `{"text": "..."}` entries)

Both files are created with defaults on first run if they don't exist.
