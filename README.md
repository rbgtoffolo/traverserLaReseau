# Traverser la Réseau - Installation Guide

This project utilizes SuperCollider for real-time sound processing. To simplify configuration, we have included scripts that automatically install the necessary dependencies on your system.

## Prerequisites
- **SuperCollider** (v3.12 or higher) must be installed.
- Audio server configured (Jack, Pipewire, or ASIO drivers on Windows).

---

## How to Start

Locate the launcher file corresponding to your Operating System in the project's root folder:

### Windows (TraverserStartWindows.bat)
1. **Path Check:** The script is pre-configured for the default path `C:\Program Files\SuperCollider-3.13.0\`. If your version is different, right-click the `.bat` file, select **Edit**, and update the `set SCLANG_PATH` line.
2. **Execution:** Double-click the file.
3. **Installation:** On the first run, the classes will be copied. If a prompt appears, close it and run the file a second time to launch the main application.

### macOS (TraverserStartMac.command)
1. **Execution Permission:** Before running for the first time, you must grant permission to the script. Open the Terminal and type `chmod +x ` (drag the file into the terminal window) and press Enter.
2. **App Path:** The script assumes SuperCollider is located in the default `/Applications` folder.
3. **Security:** If macOS blocks the app, go to *System Settings > Privacy & Security* and click "Open Anyway."
4. **Installation:** On the first run, the classes will be copied. If a prompt appears, close it and run the file a second time to launch the main application.

### Linux (TraverserStartLinux.sh)
1. **Permission:** Ensure the script is executable: `chmod +x TraverserStartLinux.sh`
2. **Execution:** Double-click or run via terminal. The script uses the `sclang` command.
3. **Nautilus:** If the script opens as text, enable "Run executable text files" in your file manager's preferences.
4. **Installation:** On the first run, the classes will be copied. If a prompt appears, close it and run the file a second time to launch the main application.
---

## Package Structure
Keep the file organization intact:
- `installer.scd`: Script that manages the installation of extensions.
- `traverser_live.scd`: The main application code.
- `Dependencies/`: Folder containing essential classes (`HarmonicTension` and `Pousseur`).
- `soundfiles/`: Audio samples used by the synthesis engine.

---

## Troubleshooting (FAQ)

**1. No sound?**
Check if the audio server (scsynth) initialized correctly. On Windows, use ASIO. On Linux, check QjackCtl.

**2. Class not defined?**
This happens if the installer failed to copy folders. Manually copy `Dependencies` contents into your SuperCollider `Extensions` folder.

**3. Program closes after first run?**
This is normal. SuperCollider terminates to register new classes. Run the launcher again.

---

If you require any further assistance, please contact the composer: rael.gimenes@gmail.com
