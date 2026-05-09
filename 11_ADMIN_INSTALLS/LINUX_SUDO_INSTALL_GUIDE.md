# Linux sudo Install Guide

## Planning

Edit:

```text
11_ADMIN_INSTALLS/ADMIN_INSTALL_MANIFEST.json
```

Set:

```json
"allow_admin_actions": true
```

Enable only approved apt/package-manager items.

## Run

```bash
python 13_SCRIPTS/admin_install_manager.py run-linux
```

The script uses sudo/package manager only when the manifest explicitly enables it.
