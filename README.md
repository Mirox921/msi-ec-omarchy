# MSI EC — Omarchy / Thin GF63 compatibility package

A documented DKMS package for **MSI Thin GF63 12VE**, EC firmware
**`16R8IMS1.108`**, and Linux kernels with the renamed ACPI battery-hook API.

[Русская инструкция](docs/README.ru.md) · [What changed](docs/CHANGES.md) ·
[Hardware validation](docs/VALIDATION.md) · [Original project](https://github.com/BeardOverflow/msi-ec)

## What this fixes

On the validated machine, the kernel-supplied `msi_ec` did not expose the
supported fan-control interfaces for this firmware. The newer upstream driver
already contains the appropriate `G2_6` firmware profile, but needed two API
name changes to compile against the installed **Linux `7.2.8-9-omarchy`** headers:

```diff
-battery_hook_register(&battery_hook);
+acpi_battery_hook_register(&battery_hook);
-battery_hook_unregister(&battery_hook);
+acpi_battery_hook_unregister(&battery_hook);
```

This repository ships that driver source, a reproducible patch, corrected DKMS
packaging, read-only compatibility checks, and installation/removal scripts.
The Makefile also detects legacy battery-hook declarations in the target
headers, rather than guessing from the kernel version.

**This is not a BIOS flash, a new firmware image, or a rewritten MControlCenter.**
Firmware support and EC register maps come from the original MSI EC project.
MControlCenter remains an optional, separately maintained GUI.

## Verified hardware

| Item | Validated value |
|---|---|
| Laptop | MSI Thin GF63 12VE |
| BIOS | `E16R8IMS.10E` |
| EC firmware | `16R8IMS1.108` |
| OS | Arch Linux / Omarchy 4 |
| Kernel | `7.2.8-9-omarchy` |
| Original local DKMS package | `msi-ec/0.13-omarchy1` |
| Repackaged version here | `msi-ec/0.13-omarchy2` |
| Optional GUI | MControlCenter `0.5.1` |

A matching marketing name alone does not establish EC compatibility. The
installer deliberately rejects other model/BIOS/EC combinations. Other devices
may be supported by upstream; this repository does not claim hardware testing
on them.

## Install on Arch / Omarchy

Read the [installation and rollback details](docs/INSTALL.md) first. Use a
source checkout or GitHub's **Code → Download ZIP**, then open a terminal in the
extracted project directory, or clone it:

```bash
git clone https://github.com/Mirox921/msi-ec-omarchy.git
cd msi-ec-omarchy
```

1. Install build dependencies and **headers for your actual kernel**:

   ```bash
   sudo pacman -S --needed base-devel dkms python
   uname -r
   ```

   `linux-headers` matches Arch's `linux`; `linux-lts-headers` matches `linux-lts`.
   For a custom Omarchy kernel, install the matching headers from its provider.
   Do not install unrelated headers and assume they match.

2. Inspect your configuration without changing it:

   ```bash
   python3 scripts/check_system.py
   ```

3. Build as your normal user:

   ```bash
   make
   ```

4. Install through DKMS, then reboot:

   ```bash
   sudo bash scripts/install.sh
   ```

   If the old driver cannot expose `fw_version`, the installer will stop.
   Follow the [documented firmware-confirmation procedure](docs/INSTALL.md#when-the-ec-version-is-not-exposed).
   Never use that option to guess or force an unsupported firmware.

5. After reboot, check that the expected module and interfaces are present:

   ```bash
   modinfo -n msi_ec
   dkms status
   cat /sys/devices/platform/msi-ec/fw_version
   cat /sys/devices/platform/msi-ec/available_fan_modes
   cat /sys/devices/platform/msi-ec/fan_mode
   ```

The installer does **not** unload the active driver, flash firmware, install a
GUI, copy personal settings, or program a custom fan curve. Activation is left
to the next reboot. DKMS builds for the running kernel; future kernel installs
rebuild through DKMS when their matching headers are available.

### Already using `0.13-omarchy1`?

If your driver works, you do not need to replace it just to use this page.
`install.sh` rejects an existing MSI EC DKMS registration instead of installing
a second version over it. See [migration notes](docs/INSTALL.md#existing-installations).

## Optional GUI: MControlCenter

[MControlCenter](https://github.com/dmitry-s93/MControlCenter) was used on the
validated machine without modifying its application binaries. Install it
separately using your distribution's package manager or its upstream release.
Check the displayed EC firmware and available modes before changing settings.

This project intentionally does not ship the original machine's EC memory dump,
raw-register write scripts, preset fan speeds, or MControlCenter configuration.
An individually tuned curve is not a portable driver compatibility fix.

## Uninstall / rollback

Close MControlCenter and disable any advanced-mode autostart you configured
separately. Then:

```bash
sudo bash scripts/uninstall.sh
```

Reboot afterwards. The script removes only this release's DKMS registration and
its own marked autoload file. It leaves other DKMS packages and user settings
alone. Check the DKMS output for restoration of the kernel's original module.
If no original module was backed up, reinstall the matching kernel package and
headers before reboot; see [rollback details](docs/INSTALL.md#rollback).

## Scope and validation limits

This is a community compatibility package, not an MSI product. The pre-existing
`omarchy1` driver was used on one physical laptop. The release source matches
that installed driver's C files; packaging has been rebuilt and checked
separately. A clean installation/reboot of `omarchy2` on another machine has
not been demonstrated. CI compilation is not hardware validation.

The driver controls an embedded controller. Use the standard automatic fan
mode as a baseline and stop if temperatures or fan behavior are abnormal.
Do not use forced firmware/debug modes or copy raw EC registers from another
laptop. Secure Boot configurations may require a signed module.

## Provenance, license, and contributions

Based on [BeardOverflow/msi-ec](https://github.com/BeardOverflow/msi-ec), upstream
commit [`d7fbbd88e6831e56801b860e46475cbf8ddbc7c1`](https://github.com/BeardOverflow/msi-ec/commit/d7fbbd88e6831e56801b860e46475cbf8ddbc7c1).
Original authorship, source notices, repository history, and [GPL licensing](LICENSE)
are retained. Original source SPDX notices specify `GPL-2.0-or-later`.

Documentation, compatibility packaging, and helper scripts were prepared with
OpenAI Codex assistance. That does not expand the hardware support claims.
Report problems using the included issue template, without serial numbers,
account keys, complete firmware dumps, or private files. See [CONTRIBUTING.md](CONTRIBUTING.md).
