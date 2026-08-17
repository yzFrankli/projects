#!/usr/bin/env python3
"""
PortScan.py - A TCP port scanner that probes all 65536 ports on a target host.
Usage: python PortScan.py <target>
"""

import socket
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

TARGET_HOST = None
open_ports = []


def scan_port(port):
    """Attempt a TCP connection to the given port. Returns port number if open, else None."""
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


def main():
    global TARGET_HOST

    if len(sys.argv) != 2:
        print("Usage: python PortScan.py <target>")
        sys.exit(1)

    TARGET_HOST = sys.argv[1]

    # Resolve hostname to IP
    try:
        socket.gethostbyname(TARGET_HOST)
    except socket.gaierror:
        # print(f"Error: Cannot resolve host '{TARGET_HOST}'")
        sys.exit(1)

    # print(f"Scanning {TARGET_HOST} ...")

    results = []
    start_time = time.time()

    # Use threads for speed while maintaining order in output
    # We scan in order 0-65535 but use concurrency to speed things up
    MAX_WORKERS = 1000
    PORT_RANGE = range(0, 65536)

    found = {}

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        future_to_port = {executor.submit(scan_port, port): port for port in PORT_RANGE}
        for future in as_completed(future_to_port):
            port = future_to_port[future]
            result = future.result()
            if result is not None:
                found[port] = get_service(port)

    elapsed = time.time() - start_time
    total_ports = len(PORT_RANGE)
    time_per_scan = elapsed / total_ports

    # Sort results by port number for ordered output
    sorted_ports = sorted(found.keys())

    lines = []
    for port in sorted_ports:
        service = found[port]
        lines.append(f"{port} ({service}) was open")

    lines.append(f"time elapsed = {elapsed:.4f}s")
    lines.append(f"time per scan = {time_per_scan:.8f}s")

    output = "\n".join(lines)
    print(output)

    with open("scanner.txt", "w") as f:
        f.write(output + "\n")

    print("\nResults saved to scanner.txt")


if __name__ == "__main__":
    main()