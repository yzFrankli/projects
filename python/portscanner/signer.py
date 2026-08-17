import socket
import argparse
import binascii
import sys
import os
from Crypto.PublicKey import RSA
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256

PORT = 9998

def mypad(somenum):
    """Pads a number to a 4-byte string as required."""
    return '0' * (4 - len(str(somenum))) + str(somenum)

def generate_keys():
    """Generates a 4096-bit RSA keypair and saves them to files."""
    # print("Generating 4096-bit RSA keypair... this might take a moment.")
    key = RSA.generate(4096)
    
    # Export and save the public key
    pubkey_pem = key.publickey().export_key()
    with open("mypubkey.pem", "wb") as pub_file:
        pub_file.write(pubkey_pem)
        
    # Export and save the private key (needed for signing later)
    privkey_pem = key.export_key()
    with open("myprivkey.pem", "wb") as priv_file:
        priv_file.write(privkey_pem)
        
    # print("Keys generated successfully.")
    # print("Public key saved to 'mypubkey.pem'.")
    # print("Private key saved to 'myprivkey.pem'.")

def sign_and_send(hostname, message):
    """Signs a message and sends it over TCP in the required format."""
    # 1. Load the private key
    if not os.path.exists("myprivkey.pem"):
        print("Error: 'myprivkey.pem' not found. Run with --genkey first.")
        sys.exit(1)
        
    with open("myprivkey.pem", "rb") as priv_file:
        private_key = RSA.import_key(priv_file.read())
        
    # 2. Hash the message using SHA256
    message_bytes = message.encode('utf-8')
    h = SHA256.new(message_bytes)
    
    # 3. Sign the hash using PKCS#1 v1.5
    signature = pkcs1_15.new(private_key).sign(h)
    
    # 4. Hexlify the signature
    signature_hex = binascii.hexlify(signature)
    
    # 5. Format the payload exactly as requested
    msg_len_str = mypad(len(message_bytes))
    sig_len_str = mypad(len(signature_hex))
    
    # Assemble the final byte sequence (No delimiters!)
    payload = (
        msg_len_str.encode('utf-8') + 
        message_bytes + 
        sig_len_str.encode('utf-8') + 
        signature_hex
    )
    
    # 6. Send over TCP to port 9998
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((hostname, PORT))
        s.sendall(payload)
        s.close()
    except ConnectionRefusedError:
        # print(f"Error: Connection refused. Is the server running on {hostname}:{PORT}?")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="RSA Message Signer")
    
    # The program works in two distinct modes
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--genkey', action='store_true', help="Generate a new 4096-bit RSA keypair")
    group.add_argument('--c', type=str, metavar='hostname', help="Connect to hostname")
    
    parser.add_argument('--m', type=str, metavar='message', help="Message to sign and send (required if using -c)")
    
    args = parser.parse_args()
    
    if args.genkey:
        generate_keys()
    elif args.c:
        if not args.m:
            parser.error("-m MESSAGE is required when using -c HOSTNAME")
        sign_and_send(args.c, args.m)

if __name__ == "__main__":
    main()