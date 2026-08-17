from Crypto.Cipher import AES
from Crypto.Hash import HMAC, SHA256
import os
import argparse
import socket
import select
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--s", action="store_true")
parser.add_argument("--c")
parser.add_argument("--confkey", required=True)
parser.add_argument("--authkey", required=True)
args = parser.parse_args()

# Keys must be bytes. For AES-256, use 32 bytes.
E_KEY = SHA256.new(args.confkey.encode()).digest()
M_KEY = SHA256.new(args.authkey.encode()).digest()

def encrypt_etm_with_length(plaintext, enc_key, mac_key):
    iv = os.urandom(16)
    # PyCryptodome CTR mode: nonce is the first 8 bytes of IV
    cipher = AES.new(enc_key, AES.MODE_CTR, nonce=iv[:8]) 
    
    msg_bytes = plaintext.encode('utf-8')
    # 1. Encrypt Length
    enc_len = cipher.encrypt(len(msg_bytes).to_bytes(4, 'big'))
    
    # 2. Header MAC: HMAC(IV + EncLen)
    h_header = HMAC.new(mac_key, digestmod=SHA256)
    h_header.update(iv + enc_len)
    mac_header = h_header.digest()
    
    # 3. Encrypt Message & Payload MAC: HMAC(EncMsg)
    enc_msg = cipher.encrypt(msg_bytes)
    h_payload = HMAC.new(mac_key, digestmod=SHA256)
    h_payload.update(enc_msg)
    mac_payload = h_payload.digest()
    
    return iv + enc_len + mac_header + enc_msg + mac_payload

def decrypt_etm_with_length(packet, enc_key, mac_key):
    # packet is bytes
    iv = packet[:16]
    enc_len = packet[16:20]
    mac_header = packet[20:52]

    # 1. Verify Header MAC
    h1 = HMAC.new(mac_key, digestmod=SHA256)
    h1.update(iv + enc_len)
    try:
        h1.verify(mac_header)
    except ValueError:
        sys.stdout.write("ERROR: HMAC verification failed\n")
        sys.exit(0)

    # 2. Decrypt length
    cipher = AES.new(enc_key, AES.MODE_CTR, nonce=iv[:8])
    msg_len = int.from_bytes(cipher.decrypt(enc_len), 'big')

    # 3. Extract message and payload MAC
    enc_msg = packet[52 : 52 + msg_len]
    mac_payload = packet[52 + msg_len : 52 + msg_len + 32]

    # 4. Verify payload MAC
    h2 = HMAC.new(mac_key, digestmod=SHA256)
    h2.update(enc_msg)
    try:
        h2.verify(mac_payload)
    except ValueError:
        return "[!] Payload Integrity Failure\n"

    # 5. Decrypt message
    return cipher.decrypt(enc_msg).decode('utf-8')

# Server side
if args.s:
    HOST = "127.0.0.1"
    PORT = 9999
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(1)
    conn, addr = s.accept()
    inputs = [conn, sys.stdin]

    while True:
        readable, _, _ = select.select(inputs, [], [])
        for r in readable:
            if r == conn:
                data = conn.recv(4096) # Use larger buffer for encrypted packets
                if not data: sys.exit()
                # Do NOT decode 'data' here; it's raw encrypted bytes
                result = decrypt_etm_with_length(data, E_KEY, M_KEY)
                sys.stdout.write(f"{result}")
                sys.stdout.flush()
            else:
                line = sys.stdin.readline()
                if not line: sys.exit()
                msg = encrypt_etm_with_length(line, E_KEY, M_KEY)
                conn.sendall(msg)

# Client side
elif args.c is not None:
    HOST = args.c
    PORT = 9999
    c = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    c.connect((HOST, PORT))
    inputs = [c, sys.stdin]

    while True:
        readable, _, _ = select.select(inputs, [], [])
        for r in readable:
            if r == c:
                data = c.recv(4096)
                if not data: sys.exit()
                result = decrypt_etm_with_length(data, E_KEY, M_KEY)
                sys.stdout.write(f"{result}")
                sys.stdout.flush()
            else: 
                line = sys.stdin.readline()
                if not line: sys.exit()
                msg = encrypt_etm_with_length(line, E_KEY, M_KEY)
                c.sendall(msg)
else:
    print("Syntax error: python encryptedim.py [--s|--c hostname] [--confkey K1] [--authkey K2]")
