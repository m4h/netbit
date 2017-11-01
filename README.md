# About
-------

Rewrite of netcat tool in assembly (Nasm x86). Most of functionality implemented by using Linux kernel ABI.
Compiled object is about ~1500 bytes in size and great for use on low memory footprint devices or to be injected somewhere >:]

# Limitations
-------------

- does not resolve hostnames to ip - hence need ip to be supplied


# Usage
-------

Connect to a port on remote node
```
┌─3t0m@BOX [netbit]
└──> $ ./netbit 205.251.183.54 80
GET / HTTP/1.1
User-Agent: None
Host: 123.net

HTTP/1.1 301 Moved Permanently
Date: Thu, 02 Nov 2017 14:33:11 GMT
Server: Apache/2.4.23 (FreeBSD) PHP/5.6.25 OpenSSL/1.0.1t-freebsd
X-Powered-By: PHP/5.6.25
Vary: Cookie
Location: https://www.123.net/
Content-Length: 0
Content-Type: text/html; charset=UTF-8
```

Listen on a port
```
┌─1t0m@BOX [netbit]
└──> $ ./netbit -l 10.0.0.127 1024
hello from other side
```

Listen on a port and pass input to `/bin/sh` (don't it in production ;])
```
┌─130t0m@BOX [netbit]
└──> $ ./netbit -e -l 10.0.0.127 1025
```

Connect with netcat, run `bash -i` and have some fun
```
┌─1t0m@BOX [netbit]
└──> $ nc -v 10.0.0.127 1025
Warning: Host 10.0.0.127 isn't authoritative! (direct lookup mismatch)
  10.0.0.127 -> BOX  BUT  BOX -> 127.0.0.1
10.0.0.127 1025 (blackjack) open
bash -i
┌─t0m@BOX [netbit]
└──> $
```
