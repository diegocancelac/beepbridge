# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller spec for BeepBridge.

Usage:
    pyinstaller build.spec --workpath server/build --distpath server/dist

Produces:
  - Windows: dist/BeepBridge.exe (onefile)
  - Linux:   dist/BeepBridge (onefile)
  - macOS:   dist/BeepBridge.app (app bundle)
"""

import sys
from pathlib import Path

block_cipher = None
HERE = Path(SPECPATH)

# Icon file per platform (set by CI, or None for dev builds)
_ico = str(HERE / "icon.ico") if (HERE / "icon.ico").exists() else None
_icns = str(HERE / "icon.icns") if (HERE / "icon.icns").exists() else None

icon_file = None
if sys.platform == "win32" and _ico:
    icon_file = _ico
elif sys.platform == "darwin" and _icns:
    icon_file = _icns

a = Analysis(
    [str(HERE / "main.py")],
    pathex=[str(HERE)],
    binaries=[],
    datas=[
        (str(HERE / "config.json"), "."),
        (str(HERE / "keys.json"), "."),
    ]
    + ([(str(HERE / "icon.png"), ".")] if (HERE / "icon.png").exists() else []),
    hiddenimports=[
        "pynput.keyboard._win32" if sys.platform == "win32" else
        "pynput.keyboard._darwin" if sys.platform == "darwin" else
        "pynput.keyboard._xorg",
        "pynput.mouse._win32" if sys.platform == "win32" else
        "pynput.mouse._darwin" if sys.platform == "darwin" else
        "pynput.mouse._xorg",
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

if sys.platform == "darwin":
    # macOS: .app bundle
    exe = EXE(
        pyz,
        a.scripts,
        [],
        exclude_binaries=True,
        name="BeepBridge",
        debug=False,
        bootloader_ignore_signals=False,
        strip=False,
        upx=False,
        console=False,
        icon=icon_file,
    )
    coll = COLLECT(
        exe,
        a.binaries,
        a.zipfiles,
        a.datas,
        strip=False,
        upx=False,
        upx_exclude=[],
        name="BeepBridge",
    )
    app = BUNDLE(
        coll,
        name="BeepBridge.app",
        icon=icon_file,
        bundle_identifier="cc.diegocancela.beepbridge",
    )
else:
    # Windows / Linux: single-file executable
    exe = EXE(
        pyz,
        a.scripts,
        a.binaries,
        a.zipfiles,
        a.datas,
        [],
        name="BeepBridge",
        debug=False,
        bootloader_ignore_signals=False,
        strip=False,
        upx=True,
        console=False,
        icon=icon_file,
    )
