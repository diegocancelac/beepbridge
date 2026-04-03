"""
BeepBridge – entry point.

Starts the system-tray icon, the tkinter settings window, and the Flask
server on a daemon thread.  The main thread drives both tkinter and pystray.
"""

import sys
import threading
import tkinter as tk

from werkzeug.serving import make_server

from config import load_config
from server import app, scan_queue
from tray import create_tray, update_tray_port
from ui import SettingsWindow


class JsonFlaskServer:
    """Thin wrapper around a werkzeug server so we can stop/restart it."""

    def __init__(self, port):
        self.port = port
        self.srv = make_server("0.0.0.0", port, app)
        self.thread = threading.Thread(target=self.srv.serve_forever, daemon=True)

    def start(self):
        self.thread.start()

    def stop(self):
        self.srv.shutdown()


def main():
    cfg = load_config()
    port = cfg.get("port", 8080)

    # ── Flask ────────────────────────────────────────────────────
    flask_server = JsonFlaskServer(port)
    flask_server.start()

    # ── tkinter (hidden at startup) ──────────────────────────────
    root = tk.Tk()
    root.withdraw()

    def restart_server(new_port):
        nonlocal flask_server
        flask_server.stop()
        flask_server = JsonFlaskServer(new_port)
        flask_server.start()
        update_tray_port(tray_icon, new_port)

    settings = SettingsWindow(root, scan_queue, restart_server)

    # ── Tray ─────────────────────────────────────────────────────
    def on_open_settings(icon, item):
        root.after(0, settings.show)

    def on_quit(icon, item):
        flask_server.stop()
        icon.stop()
        root.after(0, root.destroy)

    tray_icon = create_tray(port, on_open_settings, on_quit)

    # Run pystray in its own thread; main thread stays with tkinter.
    tray_thread = threading.Thread(target=tray_icon.run, daemon=True)
    tray_thread.start()

    root.mainloop()


if __name__ == "__main__":
    main()
