# BeepBridge

Turn your phone into a wireless barcode scanner for your desktop.

BeepBridge scans barcodes and QR codes with your phone camera and instantly types them into whatever application is focused on your computer — no drivers, no USB cables, just your local Wi-Fi network.

![BeepBridge icon](icon.png)

## How it works

1. Run the BeepBridge server on your desktop
2. Install the app on your Android phone
3. Point your phone at any barcode — it appears typed in your focused app

## Download

### Desktop server

| Platform | Download |
|----------|----------|
| Windows | [BeepBridge-windows.exe](https://github.com/diegocancelac/beepbridge/releases/latest) |
| Linux | [BeepBridge-linux.deb](https://github.com/diegocancelac/beepbridge/releases/latest) |
| macOS | [BeepBridge-macos.dmg](https://github.com/diegocancelac/beepbridge/releases/latest) |

### Android app

Available on Google Play *(coming soon)*

## Server setup

### Windows
Run `BeepBridge-windows.exe`. The app icon will appear in your system tray.

### Linux
```bash
sudo dpkg -i BeepBridge-linux.deb
beepbridge
```

### macOS
Open `BeepBridge-macos.dmg` and drag BeepBridge to your Applications folder.

> **Note:** On macOS, BeepBridge requires accessibility permissions to type into other applications. Go to System Settings → Privacy & Security → Accessibility and enable BeepBridge.

## App setup

1. Open BeepBridge on your phone
2. Tap the settings icon
3. Enter your computer's local IP address: `http://192.168.x.x:8080`
4. Tap **Test connection** to verify
5. Start scanning

**Finding your local IP:**
- Windows: `ipconfig` → IPv4 Address
- Linux: `hostname -I`
- macOS: `ipconfig getifaddr en0`

Or use the **Copy local IP** button in the server's settings window.

## Configuration

### Key sequence

After typing the barcode, the server can press additional keys automatically. Edit this via the settings window or directly in `keys.json`:
```json
[
  { "key": "tab" },
  { "text": "1" },
  { "key": "enter" }
]
```

Available special keys: `enter`, `tab`, `space`, `backspace`, `delete`, `up`, `down`, `left`, `right`, `home`, `end`, `esc`, `f1`–`f12`

### Port

Default port is `8080`. Change it in the settings window — the server restarts automatically.

## Building from source

### Server
```bash
cd server
pip install -r requirements.txt
python main.py
```

### App
```bash
cd app
flutter pub get
flutter run
```

## License

MIT
