
import argparse # use to parse arguments
import socket   # use for connection
import select   # paired with socket to wait for I/O response
import sys   # system functions



parser = argparse.ArgumentParser()
parser.add_argument("--s", action="store_true")
parser.add_argument("--c")
args = parser.parse_args()


# server side
if args.s:
        HOST = "127.0.0.1"
        PORT = 9999

        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) #TCP
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        
        s.bind((HOST, PORT))
        s.listen(1)

        conn, addr = s.accept()
        inputs = [conn, sys.stdin]

        while True:
                readable, _, _ = select.select(inputs, [], [])
                for r in readable:
                        # new connection
                        if r == conn:
                                data = conn.recv(1024)
                                # client disconnected
                                if not data:
                                        sys.exit()
                                sys.stdout.write(data.decode())
                                sys.stdout.flush()
                        else:
                                msg = sys.stdin.readline()
                                if not msg:
                                        sys.exit()
                                conn.sendall(msg.encode())

# client side
elif args.c != None:
        HOST = args.c
        PORT = 9999
        c = socket.socket(socket.AF_INET, socket.SOCK_STREAM) #TCP
        c.connect((HOST, PORT))
        inputs = [c, sys.stdin]

        while True:
                readable, _, _ = select.select(inputs, [], [])
                for r in readable:
                        # message from server
                        if r == c:
                                data = c.recv(1024)
                                if not data:
                                        sys.exit()
                                sys.stdout.write(data.decode())
                                sys.stdout.flush()
                        else: 
                                msg = sys.stdin.readline()
                                if not msg:
                                        sys.exit()
                                c.sendall(msg.encode())

else:
        print("Syntax error: python unencryptedim.py [--s] | [--c hostname]")
