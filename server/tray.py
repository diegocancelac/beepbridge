import os
import sys

import pystray
from PIL import Image, ImageDraw

_DIR = os.path.dirname(os.path.abspath(__file__))
ICON_PATH = os.path.join(_DIR, "icon.png")


def _generate_icon():
    """Create a simple green-circle-on-dark-background placeholder icon."""
    size = 64
    img = Image.new("RGBA", (size, size), (30, 30, 30, 255))
    draw = ImageDraw.Draw(img)
    margin = 12
    draw.ellipse([margin, margin, size - margin, size - margin], fill=(0, 200, 80, 255))
    img.save(ICON_PATH)
    return img


def _load_icon():
    if os.path.exists(ICON_PATH):
        return Image.open(ICON_PATH)
    return _generate_icon()


def create_tray(port, on_open_settings, on_quit):
    icon_image = _load_icon()

    menu = pystray.Menu(
        pystray.MenuItem(f"BeepBridge - Running (port {port})", None, enabled=False),
        pystray.MenuItem("Open settings", on_open_settings),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem("Quit", on_quit),
    )

    icon = pystray.Icon("BeepBridge", icon_image, "BeepBridge", menu)
    return icon


def update_tray_port(icon, port):
    """Rebuild the menu with an updated port number."""
    icon.menu = pystray.Menu(
        pystray.MenuItem(f"BeepBridge - Running (port {port})", None, enabled=False),
        pystray.MenuItem("Open settings", icon.menu._items[1]._action),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem("Quit", icon.menu._items[3]._action),
    )
    icon.update_menu()
