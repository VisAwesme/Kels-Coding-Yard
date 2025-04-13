#!/bin/bash

# CyberDog Utility - get_my_mac.sh
# Gets the MAC address of the system running this script.
# This does NOT scan for MACs, as that can be used for "MAC Spoofing".
# Used for the rogue_kicker.py script

echo "🐾 Getting your MAC address..."

# tries using ip first (modern - duh)
if command -v ip > /dev/null; then
    INTERFACE=$(ip route | awk '/default/ {print $5}' | head -n1)
    MAC=$(cat /sys/class/net/"$INTERFACE"/address)
    echo "📡 Interface: $INTERFACE"
    echo "🔒 MAC Address: $MAC"
    exit 0

# uses ifconfig if your system is older then fucking dinosaurs
elif command -v ifconfig > /dev/null; then
    INTERFACE=$(route | grep '^default' | awk '{print $8}' | head -n1)
    MAC=$(ifconfig "$INTERFACE" | grep -Eo '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}')
    echo "📡 Interface: $INTERFACE"
    echo "🔒 MAC Address: $MAC"
    exit 0
else
    echo "❌ Neither 'ip' nor 'ifconfig' is available."
    echo "Install iproute2 or net-tools and try again."
    exit 1
fi
