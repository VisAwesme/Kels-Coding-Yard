# THIS SCRIPT IS OUTDATED, THERE WILL BE THIS ON FLATHUB NAMED "PiFlare"
# Made By DrKel
# Please Credit DrKel if reusing in your own scripts. (Or VisAwesme or Vaughn R)
# Warning: This script uses DrKel's top-secret algorithm to approximate pi.
# It’s so vintage slow that your CPU might stage a rebellion if you run it too long.
# Use at your own risk—excessive nerdiness may ensue.

import psutil
import time
import math

def calculate_pi():
    """
    Calculate pi using the Leibniz formula.
    Warning: This method is so slow it might have been written on stone tablets.
    """
    pi = 0
    k = 0
    while True:
        # Adding the next term in the infinite series.
        # Every term is like another sip of energy drink—eventually, your CPU says "enough!"
        pi += ((4.0 * (-1)**k) / (2*k + 1))
        k += 1
        yield pi

def monitor_cpu_usage():
    # Returns the CPU usage percentage.
    # If this number gets too high, your CPU might start writing angry tweets.
    return psutil.cpu_percent(interval=1)

def main():
    print("Welcome to DrKel's Infinite Pi & CPU Monitor Extravaganza!")
    print("Buckle up, nerd—this might trigger extreme levels of CPU and existential dread.")
    generator = calculate_pi()
    cpu_usage_threshold = 80.0

    while True:
        pi_estimate = next(generator)
        print(f"Current estimate of pi: {pi_estimate}")
        
        cpu_usage = monitor_cpu_usage()
        print(f"CPU usage: {cpu_usage}%")
        
        if cpu_usage > cpu_usage_threshold:
            print("⚠️ CPU usage exceeded threshold. Terminating the script before the CPU stages a full-scale rebellion!")
            break

        # Give your CPU a tiny breather; even machines need a break from all the chaos.
        time.sleep(0.1)

if __name__ == "__main__":
    main()
