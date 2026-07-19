# Mwendo App - APK Build Crash Fix Guide

## Problem Summary

The APK build was failing with JVM OutOfMemoryError crashes. Analysis of crash logs revealed:

```
- hs_err_pid31476.log: JVM failed to allocate 380MB for G1 garbage collector
- hs_err_pid12604.log: Native memory allocation failed (5.8MB)
- hs_err_pid23424.log: Native memory allocation failed (1MB)
```

**Root Cause:** Windows page file (virtual memory) was at 99.4% capacity (40.7GB/41GB used), preventing JVM from allocating required memory blocks.

---

## Solution Steps

### **STEP 1: Fix Windows Page File (REQUIRES ADMINISTRATOR)**

Run the included PowerShell script **as Administrator**:

```powershell
# Right-click PowerShell → "Run as Administrator"
# Then execute:
.\fix_page_file.ps1
```

This script will:
- Disable automatic page file management
- Set page file to 16GB initial size, 32GB maximum size
- **Requires computer restart to take effect**

**Alternative Manual Method:**
1. Open **Settings → System → About → Advanced system settings**
2. **Performance → Settings → Advanced → Virtual memory → Change**
3. Uncheck "Automatically manage paging file size"
4. Set Initial size: **16384** (16GB), Maximum size: **32768** (32GB)
5. Click "Set", then "OK"
6. **Restart your computer**

---

### **STEP 2: Clean Build Artifacts**

After restarting, open a new terminal and run:

```bash
# From project root directory
flutter clean

# Delete Gradle cache (optional but recommended)
Remove-Item -Recurse -Force app\android\.gradle

# Verify Flutter environment
flutter doctor
```

---

### **STEP 3: Rebuild APK**

```bash
# Test build first (debug mode)
flutter build apk --debug

# If successful, build release APK
flutter build apk --release
```

The release APK will be generated at: `app\build\app\outputs\flutter-apk\app-release.apk`

---

## What Was Fixed

### **gradle.properties Changes:**

```properties
# Added JVM GC optimization flags
-XX:+UseG1GC -XX:MaxGCPauseMillis=200

# Reduced parallel build workers from default (auto) to 2
org.gradle.workers.max=2

# Enabled build caching to reduce memory pressure
org.gradle.caching=true
```

**Existing optimizations (already present):**
- Heap size capped at 2GB (`-Xmx2G`)
- Metaspace limited to 512MB
- Code cache limited to 256MB

---

## Verification

After rebuilding, verify the APK works:

```bash
# Install on connected device
flutter install

# Or manually install the APK
adb install app\build\app\outputs\flutter-apk\app-release.apk
```

---

## If Issues Persist

### **Option 1: Disable Gradle Daemon**

Edit `app/android/gradle.properties` and uncomment:
```properties
org.gradle.daemon=false
```

Then rebuild:
```bash
flutter clean
flutter build apk --release
```

### **Option 2: Further Reduce Memory**

Edit `app/android/gradle.properties` and reduce heap:
```properties
org.gradle.jvmargs=-Xmx1536M -XX:MaxMetaspaceSize=256m -XX:ReservedCodeCacheSize=128m -XX:+HeapDumpOnOutOfMemoryError
```

### **Option 3: Increase Page File Further**

If you have sufficient disk space, increase to:
- Initial size: 24576 (24GB)
- Maximum size: 49152 (48GB)

---

## Technical Details

### **Crash Analysis:**

**JVM Command Line:**
```
-Xmx8G → reduced to -Xmx2G (already optimized)
MaxMetaspaceSize=4G → reduced to 512m (already optimized)
```

**Why It Still Failed:**
- JVM needs virtual memory beyond the heap for:
  - G1 GC metadata: ~380MB+
  - Thread stacks: 197 threads × 1MB = ~197MB
  - Native libraries and code cache: ~300MB+
  - Metaspace for class metadata
- Total virtual memory required: ~3-4GB+
- Windows page file had only 258MB available → **CRASH**

### **System Specs:**
- CPU: Intel Core i5-1334U (12 cores)
- RAM: 24GB physical (7.7GB free)
- Page File: 41GB total (258MB free at crash time)
- OS: Windows 11 Build 26100

---

## Prevention

To avoid this issue in the future:

1. **Monitor page file usage:** Keep at least 20% free space
2. **Regular restarts:** Prevents memory fragmentation
3. **Close unused applications:** Especially browsers, IDEs, Docker
4. **Do not disable virtual memory:** Windows requires it for many operations

---

## Support

If you continue to experience issues after following this guide:

1. Check `flutter doctor` output for errors
2. Review new crash logs in `app/android/` directory
3. Ensure page file settings were applied (restart is required!)
4. Try the alternative options listed above

---

**Last Updated:** 2026-07-12
**Status: Verified & Fixed.**
- Resolved encoding parsing issues in `fix_page_file.ps1` by using standard ASCII markers.
- Verified and completed both debug (`flutter build apk --debug`) and release (`flutter build apk --release`) builds successfully.