# WARNING - THIS HAS BEEN DISABLED FOR YOUR SAFETY OF YOUR DEVICES 

# import subprocess

# a list of known allowed MAC addresses (add your legit ones)
'''

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
                        
                        
