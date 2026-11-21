# Liquid Glass 26

An iOS 26-inspired rootless visual tweak for iOS 18, with optional iOS 27-style material refinements and motion.

## Target

- Device target: **iPhone XR (A12)**
- Firmware target: **iOS 18.7.1**
- Jailbreak: **Dopamine (rootless)**
- Package managers: **Sileo / Zebra**
- Package: **Debian .deb**

## v0.2.0 features

### Lock Screen clock
- Adds a rounded translucent glass surface behind the large Lock Screen time label.
- Uses adaptive sizing based on the native clock label's actual layout bounds.
- Keeps the stock iOS 18 clock and date rendering in place rather than replacing the system time source.

### Volume and ringer HUD
- Applies a Liquid Glass material to supported SpringBoard volume and ringer HUD view classes.
- Keeps Apple's native volume and ringer controls and hardware-button behavior.

### System surfaces
- Glass appearances for navigation bars, tab bars and toolbars in selected Apple apps.
- Initial glass surfaces for supported Dock, folder, notification and Control Center containers.

### iOS 27-inspired refinements
- Adjustable glass intensity from ultra-clear to more strongly tinted.
- Brighter top highlights and more defined glass edges.
- Spring-based entrance transitions for newly presented glass surfaces.
- These are a visual approximation implemented on iOS 18, not Apple's private iOS 27 material renderer.

### Settings and performance
Open **Settings → Liquid Glass 26** to enable or disable surfaces and adjust glass intensity.

- Separate switches for system bars, Lock Screen clock, volume/ringer HUD and Dock/folders.
- Performance Mode reduces blur complexity and disables entrance animations.
- Respects iOS Reduce Motion, Reduce Transparency and Low Power Mode.
- Reuses existing visual-effect views and avoids rebuilding them on every layout pass.

## Install

1. Open the [GitHub Releases](https://github.com/mruuid/-Liquid-Glass-/releases) page.
2. Download `com.mruuid.liquidglass26_0.2.0_iphoneos-arm64.deb` from **Liquid Glass 26 v0.2.0**.
3. Install it using Sileo or Zebra.
4. Respring when prompted.
5. Open **Settings → Liquid Glass 26** to configure the effects.

## Build

Requires Theos on macOS or Linux:

```sh
make package FINALPACKAGE=1
```

The package is written to `packages/`. GitHub Actions builds the rootless package for `arm64` and `arm64e`, builds the Preferences bundle, and uploads the Debian package as an artifact.

## Important compatibility notes

This is a visual simulation, not a port of Apple's private iOS 26/27 frameworks. It styles selected native iOS 18 surfaces and relies on private SpringBoard view classes where needed. If Apple changes those class names or layouts, individual effects may not appear on that firmware.

The Lock Screen keeps Apple's native iOS 18 time layout; this release does not reproduce iOS 26 wallpaper depth/parallax, subject-aware clock repositioning, every Control Center module, app icon rendering, widgets, or every third-party app.

CI compilation and Debian packaging passed. **The package has not yet been tested on a physical iPhone XR running iOS 18.7.1**, so keep the first installation reversible and remove the package from Sileo/Zebra if you encounter SpringBoard instability.

## Uninstall

Remove **Liquid Glass 26** in Sileo or Zebra, then respring if requested.
