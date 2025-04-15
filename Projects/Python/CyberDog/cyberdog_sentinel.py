# cyberdog_sentinel.py
import os
import time
import subprocess
from modules import network_scanner, port_watcher, device_logger, rogue_kicker
# note to self - dont fucking add .py to the end of the modules... thats just a syntax error

SCAN_INTERVAL = 300  # 5 minutes - if you can count

def banner():
    print(r"""
     ██████╗ ██╗   ██╗██████╗ ██████╗  ██████╗  ██████╗  ██████╗ 
    ██╔═══██╗██║   ██║██╔══██╗██╔══██╗██╔═══██╗██╔════╝ ██╔═══██╗
    ██║   ██║██║   ██║██████╔╝██████╔╝██║   ██║██║  ███╗██║   ██║
    ██║   ██║██║   ██║██╔═══╝ ██╔═══╝ ██║   ██║██║   ██║██║   ██║
    ╚██████╔╝╚██████╔╝██║     ██║     ╚██████╔╝╚██████╔╝╚██████╔╝
     ╚═════╝  ╚═════╝ ╚═╝     ╚═╝      ╚═════╝  ╚═════╝  ╚═════╝
    """)
# i dont even know wtf this says - ill maybe fix this later
def main():
    banner()
    print("[*] Starting CyberDog Sentinel 9000...")
    
    while True:
        print("\n[+] Scanning network...")
        network_scanner.scan_network()

        print("[+] Watching ports...")
        port_watcher.watch_ports()

        print("[+] Logging connected devices...")
        device_logger.log_devices()

      #  print("[+] Checking for rogue devices...")
      #  rogue_kicker.check_and_ban()
      #  uncomment these, ONLY if you set the safe MACs on E V E R Y device in your household - i know its inefficent
      #  and i dont have a "mac scanner" for this... but uh, that can be used for mac spoofing so no.

        print(f"[*] Sleeping for {SCAN_INTERVAL} seconds...\n")
        time.sleep(SCAN_INTERVAL)

if __name__ == "__main__":
    main()
