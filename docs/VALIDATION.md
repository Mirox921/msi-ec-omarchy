# Validation record

## Physical reference system

- MSI Thin GF63 12VE, BIOS `E16R8IMS.10E`.
- EC `16R8IMS1.108`, reported release `2023-08-01T08:14:53`.
- Arch Linux / Omarchy 4, kernel `7.2.8-9-omarchy`.
- `msi-ec/0.13-omarchy1` installed through DKMS; module resolves to
  `/lib/modules/7.2.8-9-omarchy/updates/dkms/msi-ec.ko.zst`.
- Available fan-control sysfs interfaces were present in the operating system.
- MControlCenter `0.5.1` package integrity check reported zero altered files.
- Original kernel module was retained in DKMS's original-module storage.
- No new hardware-control writes were performed while preparing this project.

No serial number, complete EC memory image, private home path, screenshots of
private applications, or custom fan curve is included.

## Source provenance

The two shipped C/header files match the installed reference driver's files.
The source patch against upstream is limited to the two battery-hook API calls.
Kernel/header feature detection and DKMS installation scripts are release
packaging additions; they do not change firmware register maps.

## Release checks

See `validation/build.txt` for the local compiler/build summary after packaging.
Automated tests exercise model/BIOS/EC mismatch rejection, missing EC handling,
manual confirmation constraints and modern/legacy header detection.
CI builds against actual Arch and Ubuntu kernel headers. CI definitions are
provided; a run is not claimed successful until GitHub executes them.

The release has not been clean-installed and reboot-tested on a second laptop.
The pre-existing working `omarchy1` installation was not replaced merely to
validate distribution packaging. No new thermal/load benchmark is claimed.
