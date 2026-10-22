#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
root=$PWD
version=0.13-omarchy2
source_dir="/usr/src/msi-ec-$version"
autoload=/etc/modules-load.d/msi-ec-omarchy.conf
marker='# Managed by msi-ec-omarchy 0.13-omarchy2'

if (( $# != 0 )); then
  if (( $# != 2 )) || [[ $1 != --confirm-ec || $2 != 16R8IMS1.108 ]]; then
    echo 'Usage: sudo bash scripts/install.sh [--confirm-ec 16R8IMS1.108]' >&2
    exit 2
  fi
fi

[[ $EUID == 0 ]] || { echo 'Run with sudo after reading README.md.' >&2; exit 1; }
for cmd in dkms make python3 modinfo install; do command -v "$cmd" >/dev/null; done
python3 scripts/check_system.py --require-compatible "$@"
[[ -f /lib/modules/$(uname -r)/build/Makefile ]] || { echo 'Install matching kernel headers first.' >&2; exit 1; }
[[ ! -e $source_dir && ! -L $source_dir ]] || { echo "Refusing to overwrite $source_dir. Use the existing installation or uninstall it first." >&2; exit 1; }
existing=$(dkms status)
if [[ $existing == *msi-ec/* || $existing == *msi_ec/* ]]; then
  echo 'An MSI EC DKMS module is already registered. Do not install a second version over it.' >&2
  exit 1
fi
if [[ -e $autoload ]]; then
  echo "Refusing to overwrite existing $autoload." >&2; exit 1
fi

# Record only module provenance, never EC memory, serial numbers or user config.
backup="/var/lib/msi-ec-omarchy/$(date +%Y%m%d-%H%M%S)"
install -d -m 0700 "$backup"
modinfo msi_ec > "$backup/module-before.txt" 2>&1 || true
printf '%s\n' "$existing" > "$backup/dkms-before.txt"

added=0
succeeded=0
cleanup() {
  if (( ! succeeded )); then
    if (( added )); then dkms remove -m msi-ec -v "$version" --all || true; fi
    echo "Installation did not finish. Source and diagnostics were retained at $source_dir and $backup." >&2
  fi
}
trap cleanup EXIT
install -d -m 0755 "$source_dir"
install -m 0644 "$root/msi-ec.c" "$root/ec_memory_configuration.h" "$root/Makefile" "$root/Makefile.vars" "$root/dkms.conf" "$root/LICENSE" "$source_dir/"
dkms add -m msi-ec -v "$version"
added=1
dkms build -m msi-ec -v "$version" -k "$(uname -r)"
# No --force: respect DKMS's checks and preserve its original-module handling.
dkms install -m msi-ec -v "$version" -k "$(uname -r)"
install -d -m 0755 /etc/modules-load.d
printf '%s\n%s\n' "$marker" 'msi-ec' > "$autoload"
succeeded=1
printf '%s\n' 'Installed for the running kernel. Reboot to activate.' \
 'No module was unloaded/reloaded and no fan curve or BIOS setting was written.' \
 'After reboot: python3 scripts/check_system.py and modinfo -n msi_ec'
