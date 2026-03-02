#!/usr/bin/env bash

# init-auto-hz-change.sh: Setup power management bridge on Debian.

set -e

# Check for root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo)."
    exit 1
fi

REPO_ROOT="$(realpath "$(dirname "$0")/..")"
SCRIPTS_SRC="$REPO_ROOT/dotfiles/.local/bin/scripts"
SERVICE_SRC="$(dirname "$0")/power-profile-switch@.service"

echo "Configuring systemd service..."
REPO_SCRIPTS_DIR="$REPO_ROOT/dotfiles/.local/bin/scripts"
sed "s|@SCRIPT_PATH@|$REPO_SCRIPTS_DIR/power-bridge.sh|" "$SERVICE_SRC" > /tmp/power-profile-switch@.service

echo "Installing systemd service..."
cp /tmp/power-profile-switch@.service /etc/systemd/system/
systemctl daemon-reload

echo "Installing udev rules..."
cat <<EOF > /etc/udev/rules.d/99-power-profile.rules
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_STATUS}=="Discharging", TAG+="systemd", ENV{SYSTEMD_WANTS}="power-profile-switch@on.service"
ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_STATUS}=="Charging", TAG+="systemd", ENV{SYSTEMD_WANTS}="power-profile-switch@off.service"
EOF

echo "Reloading udev rules..."
udevadm control --reload-rules
udevadm trigger

echo "Setup complete! The system will now automatically switch refresh rates on power changes."
