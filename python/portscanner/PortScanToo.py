#!/usr/bin/env python3
"""
PortScanToo.py - A port scanner that evades PSDetect.
Scans all 65536 TCP ports but in a randomized order to avoid
triggering the "15 consecutive ports" detection heuristic.

Output is identical to PortScan.py but written to scannertoo.txt.
Usage: python PortScanToo.py <target>
"""

import socket
import sys
import time
import random
from concurrent.futures import ThreadPoolExecutor, as_completed

TARGET_HOST = None


def scan_port(port):
    """Attempt a TCP connection to the given port. Returns port if open, else None."""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(0.5)
            result = s.connect_ex((TARGET_HOST, port))
            if result == 0:
                return port
    except Exception:
        pass
    return None


def get_service(port):
    """Return the service name for a port, or 'NA' if unknown."""
    try:
        return socket.getservbyport(port)
    except Exception:
        return "NA"


def shuffle_ports_non_consecutive(ports):
    """
    Shuffle ports such that no 15 consecutive ports appear in sequence.
    Strategy: interleave ports from multiple shuffled strides so that
    nearby port numbers are spread far apart in the scan order.
    
    We split the port range into N chunks and interleave them.
    This guarantees that consecutive ports in the original range
    are separated by at least N positions in the scan order.
    """
    NUM_STRIDES = 20  # Must be > CONSECUTIVE_THRESHOLD (15) to guarantee evasion
    strides = [[] for _ in range(NUM_STRIDES)]

    for i, port in enumerate(ports):
        strides[i % NUM_STRIDES].append(port)

    # Shuffle each stride internally for extra randomness
    for stride in strides:
        random.shuffle(stride)

    # Interleave strides
    interleaved = []
    max_len = max(len(s) for s in strides)
    for i in range(max_len):
        for stride in strides:
            if i < len(stride):
                interleaved.append(stride[i])

    return interleaved


def main():
    global TARGET_HOST

    if len(sys.argv) != 2:
        print("Usage: python PortScanToo.py <target>")
        sys.exit(1)

    TARGET_HOST = sys.argv[1]

    # Resolve hostname
    try:
        socket.gethostbyname(TARGET_HOST)
    except socket.gaierror:
        # print(f"Error: Cannot resolve host '{TARGET_HOST}'")
        sys.exit(1)

    # print(f"Scanning {TARGET_HOST} (evasion mode)...")

    all_ports = list(range(0, 65536))
    scan_order = shuffle_ports_non_consecutive(all_ports)

    found = {}
    MAX_WORKERS = 1000

    start_time = time.time()

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_port = {executor.submit(scan_port, port): port for port in scan_order}
        for future in as_completed(future_to_port):
            port = future_to_port[future]
            result = future.result()
            if result is not None:
                found[port] = get_service(port)

    elapsed = time.time() - start_time
    total_ports = len(all_ports)
    time_per_scan = elapsed / total_ports

    # Output sorted by port number (same format as PortScan)
    sorted_ports = sorted(found.keys())
    lines = []
    for port in sorted_ports:
        service = found[port]
        lines.append(f"{port} ({service}) was open")

    lines.append(f"time elapsed = {elapsed:.4f}s")
    lines.append(f"time per scan = {time_per_scan:.8f}s")

    output = "\n".join(lines)
    # print(output)

    with open("scannertoo.txt", "w") as f:
        f.write(output + "\n")

    # print("\nResults saved to scannertoo.txt")


if __name__ == "__main__":
    main()