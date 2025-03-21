Hello! Welcome to uh, a play off of windows defender for linux.

To install any needed depencys run...

sudo apt-get install libcurl4-openssl-dev (Ubuntu/apt package manager)

sudo pacman -S libcurl4-openssl-dev (ARCH/pacman package manager - If that doesnt work run 'yay' or 'peru' instead of pacman)
sudo yum install libcurl4-openssl-dev (Fedora/yum package manager)

Then once those are installed...

gcc -o antivirus antivirus.c -lcurl
./antivirus file_to_scan

- These are soon too change, as this is V.0.1 (UNTESTED)
  
  3/21/2025 - Last Updated
