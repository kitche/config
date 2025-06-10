#!/bin/sh

# Ensure we're root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

echo "Updating packages..."
pkg update && pkg upgrade -y

echo "Installing Plasma 6, Wayland session, and required services..."
pkg install -y plasma6 kwin6 plasma6-wayland-session sddm xdg-desktop-portal xdg-desktop-portal-kde \
    dbus elogind seatd libinput chromium alsa-utils

echo "Enabling required services..."
sysrc sddm_enable=YES
sysrc dbus_enable=YES
sysrc elogind_enable=YES
sysrc seatd_enable=YES
sysrc sndiod_enable=YES
sysrc snd_hda_load="YES"

echo "Adding user to necessary groups..."
USER_NAME=$(logname)
pw groupmod video -m "$USER_NAME"
pw groupmod input -m "$USER_NAME"
pw groupmod wheel -m "$USER_NAME"
pw groupmod operator -m "$USER_NAME"

echo "Setting default Wayland session for fallback..."
echo 'exec dbus-launch --exit-with-session startplasma-wayland' > "/home/$USER_NAME/.xinitrc"
chown "$USER_NAME":"$USER_NAME" "/home/$USER_NAME/.xinitrc"

echo "Starting sndiod service..."
service sndiod start

echo "Setup complete. You can reboot and select Plasma (Wayland) from SDDM."
