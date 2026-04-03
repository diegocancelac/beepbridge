import time

from pynput.keyboard import Controller, Key

_keyboard = Controller()

_SPECIAL_KEYS = {name.lower(): getattr(Key, name) for name in dir(Key) if not name.startswith("_")}


def type_barcode(barcode, key_sequence):
    """Type *barcode* into the focused window, then press *key_sequence*."""
    time.sleep(0.05)  # small delay so the OS can settle focus
    _keyboard.type(barcode)

    for entry in key_sequence:
        if "key" in entry:
            k = _SPECIAL_KEYS.get(entry["key"].lower())
            if k:
                _keyboard.press(k)
                _keyboard.release(k)
        elif "text" in entry:
            _keyboard.type(entry["text"])
