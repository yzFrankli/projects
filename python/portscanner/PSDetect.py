#!/usr/bin/env python3
"""
PSDetect.py - A port scanner detector.
Listens on the loopback interface and detects if a single host connects
to 15 or more consecutive ports within a 5-minute window.

Requires superuser (root) privileges.
Usage: sudo python PSDetect.py
"""

import sys
import time
import signal
from collections import defaultdict

try:
    import scapy.all as scapy
except ImportError:
    # print("Error: scapy is required. Install with: pip install scapy")
    sys.exit(1)

OUTPUT_FILE = "detector.txt"
CONSECUTIVE_THRESHOLD = 15
TIME_WINDOW = 300  # 5 minutes in seconds

# Track connection attempts: {src_ip: [port1, port2, ...]}
# Each entry is (timestamp, port)
connection_log = defaultdict(list)

# Track already-reported scanners to avoid duplicate alerts
reported_scanners = set()


def write_detection(ip):
    msg = f"Scanner detected. The scanner originated from host {ip}."
    # print(msg)
    with open(OUTPUT_FILE, "a") as f:
        f.write(msg + "\n")


def has_consecutive_ports(ports, threshold=15):
    """Check if the list of ports contains `threshold` consecutive port numbers."""
    if len(ports) < threshold:
        return False
    sorted_ports = sorted(set(ports))
    count = 1
    for i in range(1, len(sorted_ports)):
        if sorted_ports[i] == sorted_ports[i - 1] + 1:
            count += 1
            if count >= threshold:
                return True
        else:
            count = 1
    return False


def packet_callback(packet):
    """Process each captured packet."""
    now = time.time()

    # We're looking for TCP SYN packets (connection attempts)
    if not (packet.haslayer(scapy.IP) and packet.haslayer(scapy.TCP)):
        return

    tcp = packet[scapy.TCP]
    ip = packet[scapy.IP]

    # Only look at SYN packets (flags = 0x02)
    if tcp.flags != 0x02:
        return

    src_ip = ip.src
    dst_port = tcp.dport

    # Skip already-detected scanners
    if src_ip in reported_scanners:
        return

    # Add this connection attempt with timestamp
    connection_log[src_ip].append((now, dst_port))

    # Purge old entries outside the time window
    connection_log[src_ip] = [
        (ts, p) for ts, p in connection_log[src_ip]
        if now - ts <= TIME_WINDOW
    ]

    # Extract just the ports within the window
    recent_ports = [p for _, p in connection_log[src_ip]]

    # Check for 15+ consecutive ports
    if has_consecutive_ports(recent_ports, CONSECUTIVE_THRESHOLD):
        reported_scanners.add(src_ip)
        write_detection(src_ip)


def handle_exit(sig, frame):
    # print("\nPSDetect shutting down.")
    sys.exit(0)


def main():
    signal.signal(signal.SIGINT, handle_exit)

    # print("PSDetect listening on loopback interface (lo / lo0). Press CTRL-C to stop.")

    # Try 'lo' (Linux) first, then 'lo0' (macOS)
    for iface in ["lo", "lo0"]:
        try:
            scapy.sniff(
                iface=iface,
                filter="tcp",
                prn=packet_callback,
                store=False
            )
            break
        except Exception as e:
            # print(f"Could not bind to {iface}: {e}")
            continue
    else:
        # print("Error: Could not open any loopback interface.")
        sys.exit(1)


if __name__ == "__main__":
    main()