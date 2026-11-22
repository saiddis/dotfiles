#!/usr/bin/env bash
# Install evremap@.service and enable one instance per config in ~/.config/evremap.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

sudo install -Dm644 "$here/systemd/evremap@.service" /etc/systemd/system/evremap@.service
sudo systemctl daemon-reload

for cfg in "$here"/.config/evremap/*.toml; do
  name="$(basename "$cfg" .toml)"
  sudo systemctl enable --now "evremap@${name}.service"
done
