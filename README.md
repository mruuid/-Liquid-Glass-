<div align="center">

# Liquid Glass 26

### A native-style Liquid Glass visual experience for iOS 18

[![Build](https://github.com/mruuid/-Liquid-Glass-/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/mruuid/-Liquid-Glass-/actions/workflows/build.yml)
[![Latest Release](https://img.shields.io/github/v/release/mruuid/-Liquid-Glass-?display_name=tag)](https://github.com/mruuid/-Liquid-Glass-/releases)
[![Platform](https://img.shields.io/badge/platform-iOS%2018-blue)](#compatibility)
[![Jailbreak](https://img.shields.io/badge/jailbreak-Dopamine-purple)](#requirements)
[![Package](https://img.shields.io/badge/package-rootless-orange)](#installation)

**Current version: 0.3.0**

</div>

---

## Overview

Liquid Glass 26 brings an iOS 26-inspired translucent interface to selected native iOS 18 surfaces. It is designed as a **rootless tweak** for Dopamine and is distributed as a Debian package for Sileo and Zebra.

The tweak works with existing UIKit and SpringBoard interfaces. It does not replace Apple's system frameworks or claim to reproduce Apple's private Liquid Glass renderer.

## Highlights

| Area | What it does |
| --- | --- |
| **Lock Screen** | Adds a rounded glass panel behind the native large clock label while keeping Apple's time and date rendering. |
| **Volume & ringer HUD** | Applies glass styling to supported horizontal or vertical HUD capsule views. |
| **System bars** | Styles navigation bars, tab bars and toolbars in selected Apple apps. |
| **Dock & folders** | Adds translucent material to supported SpringBoard Dock and folder surfaces. |
| **Notifications & Control Center** | Adds glass treatments to supported notification and Control Center containers. |
| **Material refinements** | Adjustable intensity, subtle highlights, defined edges and optional spring entrance motion. |
| **Performance** | Reuses visual-effect views, avoids rebuilding them on every layout pass, and offers a lightweight mode. |

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

Open **Sources → Add Source**, paste the URL, and confirm. The repository index is automatically rebuilt when a new GitHub release is published.

[Open the APT repository](https://raw.githubusercontent.com/mruuid/-Liquid-Glass-/gh-pages/)

## Installation

1. Open **[GitHub Releases](https://github.com/mruuid/-Liquid-Glass-/releases)**.
2. Download `com.mruuid.liquidglass26_0.3.0_iphoneos-arm64.deb` from **Liquid Glass 26 v0.3.0**.
3. Open the downloaded package in Sileo or Zebra and install it.
4. Respring if requested by the package manager.
5. Open **Settings → Liquid Glass 26** to configure the effects.

[**Download v0.3.0 (.deb)**](https://github.com/mruuid/-Liquid-Glass-/releases/download/v0.3.0/com.mruuid.liquidglass26_0.3.0_iphoneos-arm64.deb)

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

Liquid Glass 26 is a visual adaptation for selected iOS 18 views, not a complete iOS 26 interface port.

- The Lock Screen retains Apple's native iOS 18 clock layout. This tweak does not add wallpaper depth/parallax, subject-aware clock repositioning or a replacement clock renderer.
- Only the listed and supported system surfaces are styled. It does not restyle every Control Center module, widget, app icon or third-party app.
- Volume, ringer, notification, Dock, folder and Control Center hooks rely on private SpringBoard classes. Apple may rename or restructure those classes between point releases.
- Visual appearance can differ by wallpaper, display settings, accessibility options and individual app layouts.

**Device testing status:** GitHub Actions can verify compilation and Debian packaging, but it cannot validate SpringBoard behavior on a physical iPhone. The package should be treated as a development build until it has been tested on the target device.

## Build from source

Requires [Theos](https://theos.dev/) on macOS or Linux.

```sh
make clean
make package FINALPACKAGE=1
```

The rootless package is written to `packages/`. The project builds for `arm64` and `arm64e` and includes the Preferences bundle.

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
