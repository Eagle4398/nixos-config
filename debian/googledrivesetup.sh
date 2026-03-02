#!/usr/bin/env bash

# Exit when non-zero status
# Unset Variable -> exit error
# Stop on errored pipe | 
set -euo pipefail

for cmd in gnome-keyring-daemon secret-tool rclone; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

echo ">> Initializing Keyring..."
if ! pgrep -x "gnome-keyring-d" > /dev/null; then
    eval $(gnome-keyring-daemon --start --components=pkcs11,secrets)
    # export SSH_AUTH_SOCK
fi

echo ">> Please enter your credentials:"
read -p "Google Client ID: " CLIENT_ID
read -s -p "Google Client Secret: " CLIENT_SECRET
echo ""

read -s -p "Rclone Config Encryption Password (new or existing): " RCLONE_PASS
echo ""
echo ">> Storing rclone config password in keyring..."
printf "%s" "$RCLONE_PASS" | secret-tool store --label="Rclone Config" application rclone-config
# printf "%s" "$CLIENT_ID" | secret-tool store --label="Google OAuthID" application gdrivedrive
# printf "%s" "$CLIENT_SECRET" | secret-tool store --label="Google OAuthSecret" application gsecret
echo ">> Creating rclone.conf..."i

echo ">> Encrypting rclone config file..."

# Use Python to interact with rclone via a pseudo-terminal (PTY)
# This prevents the "Bad password" loop by simulating real keystrokes
printf "%s" "$RCLONE_PASS" | python3 -c "
import sys, os, pty, time

# Read password from stdin (the pipe)
try:
    # We add a newline because rclone expects 'Enter' after the password
    password_input = sys.stdin.read()
    if not password_input:
        sys.exit('Error: No password received on stdin')
    password = password_input + '\n'
except Exception as e:
    sys.exit(f'Error reading password: {e}')

cmd = ['rclone', 'config', 'encryption', 'set']

pid, fd = pty.fork()

if pid == 0:
    # Child: Execute rclone attached to the PTY
    os.execvp(cmd[0], cmd)
else:
    # Parent: Manage the interaction
    try:
        # 1. New Password Prompt
        time.sleep(0.5)
        os.write(fd, password.encode())
        
        # 2. Confirm Password Prompt
        time.sleep(0.5)
        os.write(fd, password.encode())
        
        # 3. Allow write-out time
        time.sleep(0.5)
    except OSError:
        pass
    finally:
        # Wait for rclone to exit
        _, status = os.waitpid(pid, 0)
        if os.WEXITSTATUS(status) != 0:
            sys.exit(1)
"

echo ">> Launching browser for Google Auth..."


export RCLONE_CONFIG_PASS="$RCLONE_PASS"
export RCLONE_CONFIG_GDRIVE_CLIENT_ID="$CLIENT_ID"
export RCLONE_CONFIG_GDRIVE_CLIENT_SECRET="$CLIENT_SECRET"
export RCLONE_CONFIG_GDRIVE_TYPE="drive"

rclone config create gdrive drive config_is_local true

echo ">> Launching browser for Google Auth..."
# # apparently will cause leak in the process tree
# rclone config create gdrivedrive drive \
#     client_id "$CLIENT_ID" \
#     client_secret "$CLIENT_SECRET" \
#     scope drive \
#     config_is_local true 

unset RCLONE_PASS RCLONE_CONFIG_PASS RCLONE_CONFIG_GDRIVE_CLIENT_ID RCLONE_CONFIG_GDRIVE_CLIENT_SECRET

echo ">> SUCCESS! Drive configured."
