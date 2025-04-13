import subprocess
from datetime import datetime

def log_devices():
    print("[Device Logger] Logging ARP table...")
    result = subprocess.check_output(["arp", "-a"]).decode()
    with open("logs/devices.log", "a") as f:
        f.write(f"--- {datetime.now()} ---\n{result}\n")
