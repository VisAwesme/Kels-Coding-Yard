# Installation Guide

Hello, and welcome to the play-off of Windows Defender for Linux! 🚨

This tool will help you scan files for potential malware using signatures. Let's get you set up with all the necessary dependencies and steps to run it.

# Step 1: Install Dependencies

Depending on your Linux distribution, use one of the following commands to install the required dependency (libcurl):

Ubuntu/Debian (apt package manager):

`sudo apt-get install libcurl4-openssl-dev`

Arch Linux (pacman package manager):

`sudo pacman -S libcurl4-openssl-dev`

If that doesn't work, try:

`yay -S libcurl4-openssl-dev`

or:

`peru -S libcurl4-openssl-dev`

Fedora/CentOS (yum package manager):

`sudo yum install libcurl4-openssl-dev`

# Step 2: Compile the Code

Once the dependencies are installed, let's compile the C program:

`gcc -o antivirus antivirus.c -lcurl`

# Step 3: Run the Malware Scan

Now that you’ve compiled the code, you can run the antivirus scanner:

`./antivirus file_to_scan`

Simply replace file_to_scan with the file you want to scan. (With file path, like `./antivirus /home/drkel/Downloads/Gorgeous_Freeman_2_Credit_Song_Loop.mp4`)

Note: These instructions are for Version 0.1 (UNTESTED) — this may change in the future!

# Version Info:

- Last Updated: 3/21/2025

- Current Version: 0.1 (UNTESTED)

![Static Badge](https://img.shields.io/badge/Linux%20Defender%20Public%20License%20(LDPL)-1?style=flat&label=License&labelColor=grey&color=lightgrey)

