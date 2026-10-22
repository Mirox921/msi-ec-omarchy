# SPDX-License-Identifier: GPL-2.0-or-later
ifneq ($(KERNELRELEASE),)
obj-m += msi-ec.o
ccflags-y += -std=gnu11 -Wno-declaration-after-statement

# Detect the API in the target kernel headers, including backported kernels.
# The driver source is identical to the locally validated modern-API variant.
MSI_EC_BATTERY_HEADER := $(srctree)/include/acpi/battery.h
ifeq ($(shell grep -cw acpi_battery_hook_register $(MSI_EC_BATTERY_HEADER)),0)
ccflags-y += -Dacpi_battery_hook_register=battery_hook_register
ccflags-y += -Dacpi_battery_hook_unregister=battery_hook_unregister
endif
else
KERNELRELEASE ?= $(shell uname -r)
KDIR ?= /lib/modules/$(KERNELRELEASE)/build

.PHONY: all modules clean check install uninstall
all: modules
modules:
	$(MAKE) -C "$(KDIR)" M="$(CURDIR)" modules
clean:
	$(MAKE) -C "$(KDIR)" M="$(CURDIR)" clean
check:
	python3 scripts/check_system.py
install:
	@echo 'Use sudo ./scripts/install.sh after reading README.md.'
	@exit 1
uninstall:
	@echo 'Use sudo ./scripts/uninstall.sh after reading README.md.'
	@exit 1
endif
