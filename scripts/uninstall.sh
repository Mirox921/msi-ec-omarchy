#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin
version=0.13-omarchy2
source_dir="/usr/src/msi-ec-$version"
autoload=/etc/modules-load.d/msi-ec-omarchy.conf
marker='# Managed by msi-ec-omarchy 0.13-omarchy2'
[[ $EUID == 0 ]] || { echo 'Run with sudo.' >&2; exit 1; }
(( $# == 0 )) || { echo 'No arguments accepted.' >&2; exit 1; }
if [[ -f $autoload ]] && ! grep -Fxq "$marker" "$autoload"; then
  echo "Refusing to remove an unrecognized $autoload." >&2; exit 1
fi
# Remove only this release. Do not touch 0.13-omarchy1 or other DKMS modules.
if dkms status -m msi-ec -v "$version" | grep -q .; then
  dkms remove -m msi-ec -v "$version" --all
fi
if [[ -f $autoload ]] && grep -Fxq "$marker" "$autoload"; then rm -- "$autoload"; fi
if [[ -d $source_dir ]] && [[ ! -L $source_dir ]] && grep -Fxq 'PACKAGE_VERSION="0.13-omarchy2"' "$source_dir/dkms.conf"; then
  rm -- "$source_dir/msi-ec.c" "$source_dir/ec_memory_configuration.h" "$source_dir/Makefile" "$source_dir/Makefile.vars" "$source_dir/dkms.conf" "$source_dir/LICENSE"
  rmdir -- "$source_dir" 2>/dev/null || echo "Build remnants kept at $source_dir."
fi
printf '%s\n' 'DKMS removal completed for 0.13-omarchy2. Reboot to use the restored kernel module.' \
 'No loaded module was hot-swapped. MControlCenter settings and fan curves were not modified.' \
 'If you separately configured MControlCenter autostart/advanced mode, disable it before reboot.'
