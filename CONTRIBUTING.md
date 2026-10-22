# Contributing

Keep hardware support claims separate from build compatibility. A successful
compile does not validate EC register mappings or thermal behavior.

For a bug report include model, BIOS, EC firmware, distribution, kernel,
`modinfo -n msi_ec`, and the small relevant part of the DKMS build error.
Remove usernames, serial numbers, keys and unrelated logs. Do not attach raw
EC dumps or fan curves to public issues by default.

Run `python3 -m unittest discover -s tests -v`, `bash -n scripts/*.sh`, and
`make` against matching target headers before proposing code changes.
Disclose AI assistance and distinguish tested results from assumptions.

This is an independent compatibility distribution. Any contribution sent to
BeardOverflow/msi-ec must separately follow that project's contribution and
AI policies; do not submit this repository wholesale as an upstream PR.
