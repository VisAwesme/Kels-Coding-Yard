# WARNING: This script is intended for use on networks you own or administratively control.
# Unauthorized use of this script to block devices on public or unauthorized networks 
# may violate cybercrime laws such as the Computer Fraud and Abuse Act (CFAA) in the U.S. 
# or the Computer Misuse Act 1990 in the U.K. Use responsibly and ethically.
# The authors of this script are not responsible for any misuse or legal consequences.

import subprocess

# a list of known allowed MAC addresses (add your legit ones)
# run get_my_mac.sh to find out YOUR MAC
# commented so you dont break your system on accident, make sure to add all the MACs in your household
"""
SAFE_MACS = ["00:11:22:33:44:55", "AA:BB:CC:DD:EE:FF"]

def get_mac_table():
   result = subprocess.check_output(["arp", "-a"]).decode().splitlines()
   macs = []
   for line in result:
       if "at" in line:
           parts = line.split()
           macs.append(parts[3])
   return macs

def check_and_ban():
   print("[Rogue Kicker] Looking for unapproved devices...")
   macs = get_mac_table()
   for mac in macs:
      if mac.lower() not in [m.lower() for m in SAFE_MACS]:
           print(f"[!] Rogue MAC detected: {mac}")
            Block device (ARP table attack)
          subprocess.call(["arptables", "-A", "OUTPUT", "--destination-mac", mac, "-j", "DROP"])

"""
                        
                        
