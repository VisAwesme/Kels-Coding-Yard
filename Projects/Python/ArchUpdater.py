import os

SERVICE_PATH = "/etc/systemd/system/arch-auto-update.service"

def normal_update():
    os.system("sudo pacman -Syu")

def advanced_update():
    backup_choice = input("Do you want to backup your current mirrorlist? (y/n): ").strip().lower()
    
    if backup_choice == "y":
        os.system("sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak")
        print("Backup saved as /etc/pacman.d/mirrorlist.bak")
    
    print("\nAvailable regions: US, CA, DE, FR, GB, AU, JP (or type 'all' for all mirrors)")
    region = input("Enter a region code (comma-separated for multiple, e.g., 'US,CA'): ").strip().upper()
    
    if region == "ALL":
        region_option = ""
    else:
        regions = region.split(",")
        region_option = " ".join([f"--country {r.strip()}" for r in regions])
    
    print("\nRefreshing mirrorlist...")
    os.system("sudo rm /etc/pacman.d/mirrorlist")
    os.system(f"sudo reflector --latest 10 --protocol https --sort rate {region_option} --save /etc/pacman.d/mirrorlist")
    
    print("Running system update...")
    os.system("sudo pacman -Syu")

def setup_autoupdate():
    if os.path.exists(SERVICE_PATH):
        print("\nAuto-update is already enabled.")
        return

    service_content = """[Unit]
Description=Arch Linux Auto Update
After=network.target

[Service]
ExecStart=/usr/bin/pacman -Syu --noconfirm
Type=oneshot
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
"""

    with open("arch-auto-update.service", "w") as f:
        f.write(service_content)

    os.system("sudo mv arch-auto-update.service /etc/systemd/system/")
    os.system("sudo systemctl daemon-reload")
    os.system("sudo systemctl enable arch-auto-update")
    
    print("\nAuto-update enabled! Your system will update automatically on startup.")

def remove_autoupdate():
    if os.path.exists(SERVICE_PATH):
        os.system("sudo systemctl disable arch-auto-update")
        os.system(f"sudo rm {SERVICE_PATH}")
        os.system("sudo systemctl daemon-reload")
        print("\nAuto-update disabled.")
    else:
        print("\nAuto-update is not enabled.")

def main():
    while True:
        print("\nArch Linux Update Script")
        print("1. Normal Update")
        print("2. Advanced Update (Refresh Mirrors)")
        print("3. Enable Auto-Update on Startup")
        print("4. Disable Auto-Update on Startup")
        print("5. Exit")

        choice = input("Select an option (1-5): ").strip()

        if choice == "1":
            normal_update()
        elif choice == "2":
            advanced_update()
        elif choice == "3":
            setup_autoupdate()
        elif choice == "4":
            remove_autoupdate()
        elif choice == "5":
            print("Exiting...")
            break
        else:
            print("Invalid option. Please enter 1-5.")

if __name__ == "__main__":
    main()
