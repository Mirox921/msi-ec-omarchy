# Installation, migration, and rollback

## Prerequisites

Use Arch / Omarchy, `base-devel`, `dkms`, `python`, and the development headers
for the running kernel. Installation requires root. Build as an ordinary user.
Other distributions and Secure Boot/module-signing setups need independent
validation; the scripts are intentionally targeted at the documented machine.

The read-only checker prints only model, BIOS, EC version, kernel and header
API. It does not print serial numbers or full DMI/EC dumps.

```bash
python3 scripts/check_system.py --require-compatible
make
sudo bash scripts/install.sh
```

The supported hardware check requires all of:

- model `Thin GF63 12VE`;
- BIOS `E16R8IMS.10E`;
- EC firmware `16R8IMS1.108`;
- target headers with either supported battery-hook API.

## When the EC version is not exposed

A missing `/sys/devices/platform/msi-ec/fw_version` can be the original reason
for installing the driver. Missing data is not treated as a successful match.
Independently verify the EC version in firmware information or an existing
read-only diagnostic tool. If MControlCenter's helper is already installed,
this is a read-only firmware query:

```bash
busctl --system call mcontrolcenter.helper /msi_ec BeardOverflow.msi_ec getFWVersion
```

Only if the actual EC version is exactly `16R8IMS1.108`, and the checker confirms
the documented model and BIOS, use:

```bash
sudo bash scripts/install.sh --confirm-ec 16R8IMS1.108
```

This is a human confirmation of otherwise unavailable data, not a force/debug
option. If the driver reports a different EC version, that mismatch cannot be
bypassed by this argument. Do not enable raw EC debug access to guess values.

## What changes

- Source copy: `/usr/src/msi-ec-0.13-omarchy2`.
- DKMS registration: `msi-ec/0.13-omarchy2`.
- Module build for the running kernel, using DKMS's original-module handling.
- A dedicated, marked `/etc/modules-load.d/msi-ec-omarchy.conf`.
- Root-only provenance records under `/var/lib/msi-ec-omarchy/`.

The script does not use `dkms install --force`. If DKMS refuses replacement,
read its error and audit the existing package; do not delete kernel modules by
hand. Failed installations attempt to remove the new DKMS registration and
retain source/diagnostic files for inspection.

No currently loaded module is unloaded. Reboot to activate the installed one.
A successful build is not proof of safe fan behavior. Check automatic mode,
temperatures and RPM before changing controls.

## Existing installations

A working `0.13-omarchy1` installation can be left as-is. If you choose to
migrate, first record `dkms status`, `modinfo -n msi_ec`, your available fan
modes and your own GUI settings. Disable any advanced-mode GUI autostart.
Use the existing package's removal procedure, ensure the original kernel
module can be restored, reboot, and then follow the installation procedure.

Do not run this release's uninstall script expecting it to remove
`0.13-omarchy1`: it deliberately removes only `0.13-omarchy2`. Distribution
packages should be removed using their package manager. Do not mix
`make install`, AUR packages and DKMS registrations for the same module.

## Rollback

Close the GUI and turn off any separately configured advanced-mode autostart.

```bash
sudo bash scripts/uninstall.sh
```

Review DKMS output for restoration of the original module. Its metadata is
recorded in the pre-install backup directory. If DKMS had no original module
to restore, reinstall your exact kernel package and matching headers using the
package manager before rebooting. Do not use a generic kernel package name
without checking your installed kernel.

Reboot and inspect `modinfo -n msi_ec`. The currently loaded module can remain
in memory until reboot; that is deliberate. Original user fan settings are not
rewritten by this project. In a previously modified system, removing a driver
package alone is not a guarantee that an individually programmed curve has
been restored; use your own independently validated configuration/backup.
