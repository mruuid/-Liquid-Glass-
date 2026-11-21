<div align="center">

# Liquid Glass 26

### A native-style Liquid Glass visual experience for iOS 18

[![Build](https://github.com/mruuid/-Liquid-Glass-/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/mruuid/-Liquid-Glass-/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/mruuid/-Liquid-Glass-?display_name=tag)](https://github.com/mruuid/-Liquid-Glass-/releases)
[![Platform](https://img.shields.io/badge/platform-iOS%2018-blue)](#compatibility)
[![Jailbreak](https://img.shields.io/badge/jailbreak-Dopamine-purple)](#requirements)
[![Package](https://img.shields.io/badge/package-rootless-orange)](#installation)

**Current version: 0.3.1**

</div>

---

## Overview

Liquid Glass 26 brings an iOS 26-inspired translucent interface to selected native iOS 18 surfaces. It is designed as a **rootless tweak** for Dopamine and is distributed as a Debian package for Sileo and Zebra.

The tweak works with existing UIKit and SpringBoard interfaces. It does not replace Apple's system frameworks or claim to reproduce Apple's private Liquid Glass renderer.

## Highlights

| Area | What it does |
| --- | --- |
| **System bars** | Styles navigation bars, tab bars and toolbars in selected Apple apps. |
| **Material refinements** | Adjustable intensity, subtle highlights, defined edges and optional spring entrance motion in supported app interfaces. |
| **Performance** | Reuses visual-effect views and offers a lightweight mode. |
| **SpringBoard effects** | Temporarily disabled in v0.3.1 as a safety measure while private system-view hooks are validated on a physical device. |

## What's new in v0.3.1

- **Safe Mode hotfix.** The tweak is no longer injected into SpringBoard by default. Private hooks for the Lock Screen clock, volume/ringer HUD, Dock, folders, notifications and Control Center are temporarily paused.
- **UIKit-only mode.** Navigation bars, tab bars and toolbars remain enabled in selected Apple apps.
- **Safer installation.** Removed the forced SpringBoard restart from package installation, so installing the hotfix does not deliberately terminate SpringBoard.
- The experimental SpringBoard hook code remains in the source but is not enabled by the package's default configuration.

This is a conservative compatibility measure, not proof of the exact crash cause. The earlier package combined several undocumented SpringBoard hooks, and the crash log from the affected device is not yet available. The private effects will be restored individually only after they can be verified safely.

## What's new in v0.3.0

- **Live settings refresh.** The tweak reloads its preference domain and invalidates visible view layouts after a setting changes. Most visual options can now update without relaunching apps or respringing.
- **Improved HUD targeting.** Volume and ringer HUD handling searches nested view hierarchies instead of requiring the outer HUD object itself to be capsule-sized.
- **Horizontal and vertical HUDs.** Capsule detection now covers both orientations while filtering out full-screen containers and small child controls.
- **More complete appearance profiles.** System bar materials refresh when glass intensity, Reduce Transparency, material refinements or Performance Mode changes.
- The Lock Screen clock, system bars, Dock/folders, notifications, Control Center and accessibility-aware rendering from v0.2.0 remain available.

## Preview

The four original preview images requested for the README are not present in the repository or in the files available to this update. They are intentionally not replaced with invented screenshots. Once supplied, they can be added to `docs/screenshots/` and displayed here.

## Requirements

- **Device target:** iPhone XR (A12)
- **Firmware target:** iOS 18.7.1
- **Jailbreak:** Dopamine, rootless
- **Package manager:** Sileo or Zebra
- **Architecture:** arm64 / arm64e
- **Dependencies:** ElleKit (or MobileSubstrate) and PreferenceLoader

The package declares iOS 18 or later as its minimum firmware requirement. Actual support depends on the availability and layout of private SpringBoard view classes on the installed iOS build.

## APT Repository (Sileo / Zebra)

Add the official Liquid Glass 26 source to Sileo or Zebra:

`https://raw.githubusercontent.com/mruuid/-Liquid-Glass-/gh-pages/`

[Add to Sileo](sileo://source/https://raw.githubusercontent.com/mruuid/-Liquid-Glass-/gh-pages/) · [Add to Zebra](zbra://sources/add/https://raw.githubusercontent.com/mruuid/-Liquid-Glass-/gh-pages/)

In either app, open **Sources → Add Source**, paste the URL above, and confirm. The repository automatically rebuilds after each published GitHub release.

The APT index includes all published Liquid Glass versions for version selection and downgrades. The repository is served over HTTPS, but its `Release` file is currently **not GPG-signed**.

[Browse repository files](https://github.com/mruuid/-Liquid-Glass-/tree/gh-pages)

## Installation

1. Open **[GitHub Releases](https://github.com/mruuid/-Liquid-Glass-/releases)**.
2. Download `com.mruuid.liquidglass26_0.3.1_iphoneos-arm64.deb` from **Liquid Glass 26 v0.3.1**.
3. Open the downloaded package in Sileo or Zebra and install it.
4. Respring if requested by the package manager.
5. Open **Settings → Liquid Glass 26** to configure the effects.

[**Download v0.3.1 (.deb)**](https://github.com/mruuid/-Liquid-Glass-/releases/download/v0.3.1/com.mruuid.liquidglass26_0.3.1_iphoneos-arm64.deb)

## Settings

Open **Settings → Liquid Glass 26**.

| Option | Description |
| --- | --- |
| Enable Liquid Glass | Master switch for the tweak. |
| Glass Intensity | Adjusts the strength of the glass tint and material profile. |
| iOS 27 Material Refinements | Enables stronger highlights, edge contrast and refined entrance motion. This is an approximation, not Apple's iOS 27 renderer. |
| System Bars | Toggles navigation bars, tab bars and toolbars. |
| Lock Screen Clock | Toggles the glass surface behind the native Lock Screen clock. |
| Volume and Ringer HUD | Toggles supported volume and ringer HUD surfaces. |
| Dock and Folders | Toggles supported Dock and folder surfaces. |
| Performance Mode | Reduces blur complexity and disables entrance animations. |

The tweak also respects the system's **Reduce Motion**, **Reduce Transparency** and **Low Power Mode** settings.

## Compatibility & limitations

Liquid Glass 26 is a visual adaptation for selected iOS 18 views, not a complete iOS 26 interface port. In v0.3.1, SpringBoard injection is intentionally disabled to avoid the Safe Mode regression reported with earlier builds.

- The Lock Screen retains Apple's native iOS 18 clock layout. This tweak does not add wallpaper depth/parallax, subject-aware clock repositioning or a replacement clock renderer.
- Only the listed and supported system surfaces are styled. It does not restyle every Control Center module, widget, app icon or third-party app.
- Private SpringBoard effects (Lock Screen clock, volume/ringer HUD, Dock, folders, notifications and Control Center) are disabled in v0.3.1. They rely on undocumented classes and will remain disabled until individually verified on-device.
- Visual appearance can differ by wallpaper, display settings, accessibility options and individual app layouts.

**Device testing status:** GitHub Actions can verify compilation and Debian packaging, but it cannot validate SpringBoard behavior on a physical iPhone. The package should be treated as a development build until it has been tested on the target device.

## Build from source

Requires [Theos](https://theos.dev/) on macOS or Linux.

```sh
make clean
make package FINALPACKAGE=1
```

The rootless package is written to `packages/`. The project builds for `arm64` and `arm64e` and includes the Preferences bundle. The v0.3.1 package does not inject into SpringBoard; it styles supported UIKit bars in selected apps.

GitHub Actions automatically builds the Debian package on pushes to `main`, pull requests and manual workflow dispatches. Successful builds are uploaded as the `liquid-glass-deb` workflow artifact. The release workflow verifies package identity, version and architecture before publishing a tagged release.

## Troubleshooting

- **A setting does not appear to change:** reopen the affected interface. Some private SpringBoard surfaces only update when iOS lays them out again.
- **An effect is missing:** the corresponding private view class or layout may differ on your firmware.
- **SpringBoard becomes unstable:** boot into the jailbreak's safe mode if necessary, remove **Liquid Glass 26** in Sileo or Zebra, and respring.
- **Performance is reduced:** enable **Performance Mode**, lower Glass Intensity, or disable individual surfaces.

## Uninstall

Remove **Liquid Glass 26** in Sileo or Zebra, then respring if requested.

---

<div align="center">

Made for a cleaner, glass-inspired iOS experience.

[Releases](https://github.com/mruuid/-Liquid-Glass-/releases) · [Build workflow](https://github.com/mruuid/-Liquid-Glass-/actions/workflows/build.yml) · [Source](https://github.com/mruuid/-Liquid-Glass-)

</div>
