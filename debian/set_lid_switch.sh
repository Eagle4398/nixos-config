#!/usr/bin/env bash

cat "./$0"

FILE="/etc/systemd/logind.conf"

sudo sed -i 's/^#\?\(HandleLidSwitch=\).*/\1suspend/' "$FILE"
sudo sed -i 's/^#\?\(HandleLidSwitchExternalPower=\).*/\1suspend/' "$FILE"

sudo systemctl restart systemd-logind
