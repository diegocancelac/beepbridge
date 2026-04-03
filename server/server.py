import queue
from datetime import datetime

from flask import Flask, jsonify, request

from config import load_keys
from typer import type_barcode

app = Flask(__name__)

scan_queue: queue.Queue = queue.Queue()


@app.route("/scan", methods=["POST"])
def scan():
    data = request.get_json(silent=True)
    if not data or "barcode" not in data:
        return jsonify({"error": "Missing 'barcode' field"}), 400

    barcode = str(data["barcode"])
    keys = load_keys()
    type_barcode(barcode, keys)

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    scan_queue.put((timestamp, barcode))

    return jsonify({"ok": True, "barcode": barcode}), 200


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "running"}), 200
