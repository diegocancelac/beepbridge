import socket
import tkinter as tk
from tkinter import ttk, messagebox

from config import load_config, save_config, load_keys, save_keys


class SettingsWindow:
    MAX_LOG = 20

    def __init__(self, root, scan_queue, restart_server_cb):
        self.root = root
        self.scan_queue = scan_queue
        self.restart_server_cb = restart_server_cb

        self.root.title("BeepBridge Settings")
        self.root.geometry("520x560")
        self.root.resizable(False, False)
        self.root.protocol("WM_DELETE_WINDOW", self._on_close)

        self._build_ui()
        self._load_current()
        self._poll_queue()

    # ── UI construction ──────────────────────────────────────────────

    def _build_ui(self):
        pad = {"padx": 8, "pady": 4}

        # --- Port ---
        port_frame = ttk.LabelFrame(self.root, text="Server")
        port_frame.pack(fill="x", **pad)

        ttk.Label(port_frame, text="Port:").grid(row=0, column=0, sticky="w", padx=4, pady=4)
        self.port_var = tk.StringVar()
        ttk.Entry(port_frame, textvariable=self.port_var, width=8).grid(row=0, column=1, sticky="w", padx=4, pady=4)

        ttk.Button(port_frame, text="Copy local IP", command=self._copy_ip).grid(row=0, column=2, padx=12, pady=4)

        # --- Key sequence editor ---
        keys_frame = ttk.LabelFrame(self.root, text="Key sequence (after barcode)")
        keys_frame.pack(fill="x", **pad)

        self.keys_list = tk.Listbox(keys_frame, height=5)
        self.keys_list.pack(side="left", fill="both", expand=True, padx=4, pady=4)

        btn_col = ttk.Frame(keys_frame)
        btn_col.pack(side="right", padx=4, pady=4)

        self.type_var = tk.StringVar(value="key")
        ttk.Radiobutton(btn_col, text="Key", variable=self.type_var, value="key").pack(anchor="w")
        ttk.Radiobutton(btn_col, text="Text", variable=self.type_var, value="text").pack(anchor="w")

        self.value_var = tk.StringVar()
        ttk.Entry(btn_col, textvariable=self.value_var, width=12).pack(pady=2)

        ttk.Button(btn_col, text="Add", command=self._add_key).pack(fill="x", pady=1)
        ttk.Button(btn_col, text="Delete", command=self._del_key).pack(fill="x", pady=1)

        # --- Scan log ---
        log_frame = ttk.LabelFrame(self.root, text="Recent scans")
        log_frame.pack(fill="both", expand=True, **pad)

        self.log_text = tk.Text(log_frame, state="disabled", height=10, wrap="none")
        scrollbar = ttk.Scrollbar(log_frame, orient="vertical", command=self.log_text.yview)
        self.log_text.configure(yscrollcommand=scrollbar.set)
        scrollbar.pack(side="right", fill="y")
        self.log_text.pack(fill="both", expand=True, padx=4, pady=4)

        self._log_lines = []

        # --- Bottom buttons ---
        bottom = ttk.Frame(self.root)
        bottom.pack(fill="x", **pad)
        ttk.Button(bottom, text="Save", command=self._save).pack(side="right", padx=4, pady=4)

    # ── Data ─────────────────────────────────────────────────────────

    def _load_current(self):
        cfg = load_config()
        self.port_var.set(str(cfg.get("port", 8080)))

        self._keys_data = load_keys()
        self._refresh_keys_list()

    def _refresh_keys_list(self):
        self.keys_list.delete(0, "end")
        for entry in self._keys_data:
            if "key" in entry:
                self.keys_list.insert("end", f"[key] {entry['key']}")
            elif "text" in entry:
                self.keys_list.insert("end", f"[text] {entry['text']}")

    def _add_key(self):
        kind = self.type_var.get()
        value = self.value_var.get().strip()
        if not value:
            return
        self._keys_data.append({kind: value})
        self._refresh_keys_list()
        self.value_var.set("")

    def _del_key(self):
        sel = self.keys_list.curselection()
        if not sel:
            return
        idx = sel[0]
        self._keys_data.pop(idx)
        self._refresh_keys_list()

    # ── Actions ──────────────────────────────────────────────────────

    def _save(self):
        try:
            port = int(self.port_var.get())
            if not (1 <= port <= 65535):
                raise ValueError
        except ValueError:
            messagebox.showerror("Invalid port", "Port must be an integer between 1 and 65535.")
            return

        old_cfg = load_config()
        new_cfg = {**old_cfg, "port": port}
        save_config(new_cfg)
        save_keys(self._keys_data)

        if old_cfg.get("port") != port:
            self.restart_server_cb(port)

        messagebox.showinfo("Saved", "Configuration saved.")

    def _copy_ip(self):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
        except Exception:
            ip = "127.0.0.1"
        self.root.clipboard_clear()
        self.root.clipboard_append(ip)
        messagebox.showinfo("Copied", f"Local IP copied: {ip}")

    def _on_close(self):
        self.root.withdraw()

    # ── Queue polling ────────────────────────────────────────────────

    def _poll_queue(self):
        while not self.scan_queue.empty():
            timestamp, barcode = self.scan_queue.get_nowait()
            line = f"[{timestamp}] {barcode}"
            self._log_lines.append(line)
            if len(self._log_lines) > self.MAX_LOG:
                self._log_lines = self._log_lines[-self.MAX_LOG:]
            self._refresh_log()
        self.root.after(250, self._poll_queue)

    def _refresh_log(self):
        self.log_text.configure(state="normal")
        self.log_text.delete("1.0", "end")
        self.log_text.insert("end", "\n".join(self._log_lines))
        self.log_text.see("end")
        self.log_text.configure(state="disabled")

    # ── Public helpers ───────────────────────────────────────────────

    def show(self):
        self.root.deiconify()
        self.root.lift()
