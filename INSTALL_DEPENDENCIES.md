# 🔧 Install Missing Dependencies

## The Issue
You're missing the C++ compiler and build tools needed for Linux desktop apps.

## Quick Fix (1 command!)

Run this command and enter your password when prompted:

```bash
sudo apt-get update && sudo apt-get install -y \
  clang cmake ninja-build pkg-config \
  libgtk-3-dev liblzma-dev libstdc++-12-dev
```

This installs:
- **clang** - C++ compiler
- **cmake** - Build system
- **ninja-build** - Fast builder
- **pkg-config** - Package management
- **libgtk-3-dev** - GTK libraries for UI
- **liblzma-dev** - Compression library
- **libstdc++-12-dev** - C++ standard library

## Installation Time
⏱️ About 2-3 minutes

## After Installation

Once installed, run your app:

```bash
cd ~/Workspace/rescue_1122_emergency_app
./RUN_APP.sh
```

## Verification

To check if installed correctly:

```bash
clang++ --version
cmake --version
```

Should show version numbers.

---

## Alternative: Use Web Instead

If you don't want to install build tools, run on Web:

```bash
cd ~/Workspace/rescue_1122_emergency_app
flutter run -d chrome
```

No installation needed! Opens in browser.

---

## Step-by-Step

**Step 1:** Install dependencies
```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

**Step 2:** Run your app
```bash
./RUN_APP.sh
```

**Step 3:** Wait for build (2-3 min first time)

**Step 4:** App window opens!

---

## What Each Package Does

| Package | Purpose |
|---------|---------|
| clang | C++ compiler for building native code |
| cmake | Build system generator |
| ninja-build | Fast build tool |
| pkg-config | Manages library compile/link flags |
| libgtk-3-dev | GTK3 UI toolkit |
| liblzma-dev | LZMA compression library |
| libstdc++-12-dev | C++ standard library |

---

## After Installation Works

Once dependencies are installed:

✅ Linux desktop app builds
✅ Native window opens
✅ Full app functionality
✅ Fast hot reload
✅ Professional UI

---

## Quick Reference

**Install dependencies:**
```bash
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev
```

**Run app:**
```bash
./RUN_APP.sh
```

**Or use Web (no install needed):**
```bash
flutter run -d chrome
```

---

**Next: Run the install command above, then run your app!**
