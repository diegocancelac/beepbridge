import json
import os

_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(_DIR, "config.json")
KEYS_PATH = os.path.join(_DIR, "keys.json")

_DEFAULTS = {"port": 8080}
_DEFAULT_KEYS = [{"key": "enter"}]


def load_config():
    if not os.path.exists(CONFIG_PATH):
        save_config(_DEFAULTS)
        return dict(_DEFAULTS)
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def save_config(cfg):
    with open(CONFIG_PATH, "w", encoding="utf-8") as f:
        json.dump(cfg, f, indent=2)


def load_keys():
    if not os.path.exists(KEYS_PATH):
        save_keys(_DEFAULT_KEYS)
        return list(_DEFAULT_KEYS)
    with open(KEYS_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def save_keys(keys):
    with open(KEYS_PATH, "w", encoding="utf-8") as f:
        json.dump(keys, f, indent=2)
