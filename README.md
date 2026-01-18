---

# Traverser la Réseau - Installation Guide

This project utilizes SuperCollider for real-time sound processing. To simplify configuration, we have included scripts that automatically install the necessary dependencies on your system.

## Prerequisites

* **SuperCollider** (v3.12 or higher) must be installed.
* Audio server configured (Jack, Pipewire, or ASIO drivers on Windows).

---

## 🚀 How to Start

Locate the launcher file corresponding to your Operating System in the project's root folder:

### 🪟 Windows (`TraverserStartWindows.bat`)

1. **Path Check:** The script is pre-configured for the default path `C:\Program Files\SuperCollider-3.13.0\`. If your version is different (e.g., 3.12 or 3.14), right-click the `.bat` file, select **Edit**, and update the `set SCLANG_PATH` line.
2. **Execution:** Double-click the file.
3. **Installation:** On the first run, the classes will be copied. If a prompt appears, close it and run the file a second time to launch the main application.

### 🍎 macOS (`TraverserStartMac.command`)

1. **Execution Permission:** Before running for the first time, you must grant permission to the script. Open the Terminal and type:
`chmod +x ` (drag the file into the terminal window to complete the path) and press Enter.
2. **App Path:** The script assumes SuperCollider is located in the default `/Applications` folder.
3. **Security:** If macOS blocks the app as an "Unidentified Developer," go to *System Settings > Privacy & Security* and click "Open Anyway."

### 🐧 Linux (`TraverserStartLinux.sh`)

1. **Permission:** Ensure the script is executable:
`chmod +x TraverserStartLinux.sh`
2. **Execution:** Double-click or run via terminal. The script uses the `sclang` command (ensure it is in your `$PATH`).
3. **Nautilus:** If the script opens as a text file, check your file manager's preferences and enable the option "Run executable text files when they are opened."

---

## 📂 Package Structure

Keep the file organization intact so that internal paths function correctly:

* `installer.scd`: Script that manages the installation of extensions.
* `traverser_live.scd`: The main application code.
* `Dependencies/`: Folder containing essential classes (`HarmonicTension` and `Pousseur`).
* `soundfiles/`: Audio samples (cello, cracks, etc.) used by the synthesis engine.

---

## ⚠️ Troubleshooting (FAQ)

**1. The program opens but there is no sound?**

* Check if the audio server (scsynth) initialized correctly. On Windows, the use of ASIO drivers is highly recommended. On Linux, check your connections in QjackCtl or similar.

**2. "Class not defined" error?**

* This happens if the installer was unable to copy the folders to the SuperCollider `Extensions` folder. You can manually copy the contents of the `Dependencies` folder into your user's SuperCollider extensions directory.

**3. The program closes immediately after the first run?**

* This is normal. SuperCollider needs to terminate the process to register the newly installed classes. Simply open the launcher a second time.

---

If you require any further assistance, please contact the composer: rael.gimenes@gmail.com

---

