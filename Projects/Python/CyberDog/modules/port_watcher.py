import subprocess

def watch_ports():
    print("[Port Watcher] Checking open ports...")
    result = subprocess.check_output(["ss", "-tuln"]).decode()
    with open("logs/ports.log", "a") as f:
        f.write(result + "\n")
