import subprocess

def scan_network():
    print("[Network Scanner] Running nmap...")
# idfk
subprocess.call(["nmap", "-sn", "192.168.1.0/24"])
