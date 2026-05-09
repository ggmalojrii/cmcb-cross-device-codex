# Windows Admin Install Guide

## Planning

Edit:

```text
11_ADMIN_INSTALLS/ADMIN_INSTALL_MANIFEST.json
```

Set:

```json
"allow_admin_actions": true
```

Enable only the package/installer you want.

## Run

```powershell
powershell -ExecutionPolicy Bypass -File .\13_SCRIPTS\run_admin_install_windows.ps1
```

Expected behavior:
- prints plan
- blocks unless admin actions are enabled
- uses UAC prompt for admin elevation
- logs results
- validates installed command if configured

## Do not

- disable UAC
- bypass UAC
- store admin password
- run unknown installers
- use silent install unless you reviewed arguments
