#!/usr/bin/env bash

POLICY_FILE="/etc/polkit-1/localauthority/50-local.d/allow_reboot.pkla"
CONTENT="[Allow Reboot]
Identity=unix-user:*
Action=org.freedesktop.login1.reboot;org.freedesktop.login1.reboot-multiple-sessions
ResultAny=yes
ResultInactive=yes
ResultAllowed=yes"

mkdir -p "$(dirname "$POLICY_FILE")"

echo "$CONTENT" > "$POLICY_FILE"

chmod 644 "$POLICY_FILE"

echo "Policy created at $POLICY_FILE"
