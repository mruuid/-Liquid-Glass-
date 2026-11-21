# Liquid Glass 26

Liquid Glass 26 — rootless iOS tweak that brings an iOS 26-inspired glass material to selected system interfaces on iOS 18.

## Target device

- Device used for the initial compatibility target: **iPhone XR (A12)**
- Firmware target: **iOS 18.7.1**
- Jailbreak: **Dopamine**
- Package managers: **Sileo / Zebra**
- Package type: **rootless Debian package (.deb)**

Dopamine support for A13-and-earlier devices on iOS 17.4–18.7.1 is listed by the iOS Guide. This project targets the rootless Theos package scheme.

## Current implementation (0.1.0)

- Applies a thin system blur material to navigation bars, tab bars, and toolbars in selected Apple apps.
- Adds a translucent, rounded glass surface to selected SpringBoard dock, folder, and notification views when those private view classes are present.
- Uses ElleKit/Substrate-compatible injection and Theos rootless packaging.
- Restricts injection to selected Apple system apps rather than every third-party app, to reduce compatibility risk.

This is an initial development build, not a complete recreation of every iOS 26 interface. Lock Screen, Control Center layout, app icons, widgets, and third-party app theming still need separate implementation and device testing.

## Build

Build on macOS or Linux with Theos installed:

```sh
make package FINALPACKAGE=1
```

The package is written to `packages/`. The GitHub Actions workflow also builds the package and uploads the `.deb` as a workflow artifact.

## Install

1. Open the repository's **Actions** tab on GitHub.
2. Open the latest successful **Build Liquid Glass** workflow.
3. Download the `liquid-glass-deb` artifact and extract the `.deb`.
4. Install the rootless package using Sileo or Zebra.

Do not install a package from a failed or incomplete build. The first release must be tested on the target iPhone XR before being treated as stable.

## Uninstall

Remove **Liquid Glass 26** in Sileo or Zebra, then respring if requested.

## Project layout

- `Tweak.xm` — UIKit appearance hooks and SpringBoard glass surfaces.
- `LiquidGlass.plist` — process injection filter.
- `Makefile` — rootless Theos build configuration.
- `control` — Debian package metadata.
- `.github/workflows/build.yml` — automated package build.

## Compatibility

The current target is iOS 18.7.1 on iPhone XR. Other iOS versions and devices are not yet declared supported. Private SpringBoard class names can change between iOS releases, so those effects are applied only when the corresponding class exists at runtime.
