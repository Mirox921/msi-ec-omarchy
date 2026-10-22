# Change audit

## Upstream base

Repository: https://github.com/BeardOverflow/msi-ec

Commit: `d7fbbd88e6831e56801b860e46475cbf8ddbc7c1`

The installed `msi-ec.c` differs from this commit in exactly two calls:
`battery_hook_register` → `acpi_battery_hook_register`, and
`battery_hook_unregister` → `acpi_battery_hook_unregister`.
`ec_memory_configuration.h` is unchanged. The precise source diff is in
[patches/0001-linux-acpi-battery-hooks.patch](../patches/0001-linux-acpi-battery-hooks.patch).

No EC address, firmware allowlist entry, fan mode value, or BIOS data was
invented for this distribution. `16R8IMS1.108` is already in upstream's
`ALLOWED_FW_G2_6` and uses its `CONF_G2_6` mapping.

## Existing local installation: 0.13-omarchy1

The system used an out-of-tree DKMS driver in place of its kernel module.
The original kernel module was retained under DKMS's `original_module`
directory. MControlCenter was installed without changing package binaries.
User fan curves, application autostart, and module autoload were configured
separately. Those machine-specific curves and EC backup files are excluded.

This project does not claim that the entire driver or MControlCenter was
rewritten. Replacing an older kernel driver with newer upstream code and
making it compile are distinct from writing a new firmware profile.

## Distribution packaging: 0.13-omarchy2

- Preserve the C source from the working installation.
- Detect renamed versus legacy ACPI battery-hook declarations in target
  kernel headers. Use build-time aliases for legacy headers.
- Replace upstream installation Makefile targets with explicit DKMS scripts.
  The installed local Makefile used `msi_ec` in one source path while its
  DKMS package name was `msi-ec`, and referenced an unshipped uninstall helper.
- Add model/BIOS/EC checks and reject unsupported or ambiguous configurations.
- Reject an existing MSI EC DKMS registration instead of replacing it blindly.
- Install no fan curves, raw EC writer, firmware dump, GUI or GUI autostart.
- Activate on reboot; never unload an active hardware driver automatically.
- Keep version-specific rollback and pre-install module provenance.
- Provide English/Russian docs, build CI and compatibility-check tests.

The compatibility packaging is a new distribution of the previously tested
source, not a claim that an `omarchy2` installation has already been boot-tested.
