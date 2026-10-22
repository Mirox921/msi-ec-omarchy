#!/usr/bin/env python3
"""Read-only preflight. Does not load modules or read/write raw EC memory."""
import argparse
import json
import platform
import re
from pathlib import Path

MODEL = 'Thin GF63 12VE'
BIOS = 'E16R8IMS.10E'
EC = '16R8IMS1.108'


def read(path):
    try:
        return Path(path).read_text().strip()
    except (OSError, UnicodeError):
        return None


def inspect(root=Path('/'), kernel=None, confirmed_ec=None):
    kernel = kernel or platform.release()
    dmi = root / 'sys/class/dmi/id'
    ec = read(root / 'sys/devices/platform/msi-ec/fw_version')
    header = root / 'lib/modules' / kernel / 'build/include/acpi/battery.h'
    text = read(header) or ''
    api = ('modern' if re.search(r'\bacpi_battery_hook_register\s*\(', text)
           else 'legacy' if re.search(r'\bbattery_hook_register\s*\(', text) else 'unknown')
    model = read(dmi / 'product_name')
    bios = read(dmi / 'bios_version')
    confirmed = not ec and confirmed_ec == EC
    compatible = model == MODEL and bios == BIOS and (ec == EC or confirmed) and api != 'unknown'
    return dict(model=model, bios=bios, ec_firmware=ec, kernel=kernel,
                battery_api=api, ec_manually_confirmed=confirmed,
                matches_tested_configuration=compatible)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--json', action='store_true')
    p.add_argument('--require-compatible', action='store_true')
    p.add_argument('--confirm-ec', choices=[EC], help='Only if independently verified; not a firmware override.')
    args = p.parse_args()
    result = inspect(confirmed_ec=args.confirm_ec)
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        for key, value in result.items():
            print(f'{key}: {value if value is not None else "not available"}')
        print('This check does not prove safe fan-curve addresses for another machine.')
    return 0 if not args.require_compatible or result['matches_tested_configuration'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
