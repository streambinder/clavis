#!/usr/bin/env python3
import sys, socket, ssl, threading, os, base64, urllib.parse
host, port, proxy_host, proxy_port = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])

# Use env proxy with auth (like the version that worked)
egress = os.environ.get('https_proxy') or os.environ.get('HTTPS_PROXY') or os.environ.get('http_proxy') or ''
egress_host = None
egress_port = None
egress_auth = None
if egress:
    if '://' in egress:
        _, rest = egress.split('://',1)
    else:
        rest = egress
    if '@' in rest:
        creds, rest = rest.rsplit('@',1)
        egress_auth = creds
    if ':' in rest:
        h, p = rest.rsplit(':',1)
        egress_host = h
        try:
            egress_port = int(p)
        except:
            egress_port = 3128
    else:
        egress_host = rest
        egress_port = 3128

if egress_host:
    s = socket.create_connection((egress_host, egress_port), timeout=12)
    auth_hdr = ""
    if egress_auth:
        b64 = base64.b64encode(egress_auth.encode()).decode()
        auth_hdr = f"Proxy-Authorization: Basic {b64}\r\n"
    s.sendall(f"CONNECT {proxy_host}:{proxy_port} HTTP/1.1\r\nHost: {proxy_host}:{proxy_port}\r\n{auth_hdr}\r\n".encode())
    resp = b""
    s.settimeout(10)
    while b"\r\n\r\n" not in resp:
        chunk = s.recv(4096)
        if not chunk:
            break
        resp += chunk
    if b" 200 " not in resp.split(b"\r\n",1)[0]:
        sys.stderr.write(f"egress fail {resp[:500]}\n")
        sys.exit(1)
else:
    s = socket.create_connection((proxy_host, proxy_port), timeout=12)

ctx = ssl.create_default_context()
cs = ctx.wrap_socket(s, server_hostname=proxy_host)
cs.sendall(f"CONNECT {host}:{port} HTTP/1.1\r\nHost: {host}:{port}\r\nConnection: close\r\n\r\n".encode())
resp = b""
cs.settimeout(10)
while b"\r\n\r\n" not in resp:
    chunk = cs.recv(4096)
    if not chunk:
        break
    resp += chunk
if b" 200 " not in resp.split(b"\r\n",1)[0]:
    sys.stderr.write(f"inner fail {resp[:800]}\n")
    sys.exit(1)

idx = resp.find(b"\r\n\r\n")
leftover = resp[idx+4:] if idx!=-1 else b""

stdout_fd = sys.stdout.fileno()
stdin_fd = sys.stdin.fileno()
if leftover:
    os.write(stdout_fd, leftover)

def to_remote():
    try:
        while True:
            data = os.read(stdin_fd, 16384)
            if not data:
                try:
                    cs.shutdown(socket.SHUT_WR)
                except:
                    pass
                break
            cs.sendall(data)
    except:
        pass

def to_local():
    try:
        while True:
            data = cs.recv(16384)
            if not data:
                break
            os.write(stdout_fd, data)
    except:
        pass

t1 = threading.Thread(target=to_remote, daemon=True)
t2 = threading.Thread(target=to_local, daemon=True)
t1.start()
t2.start()
t1.join()
t2.join()
