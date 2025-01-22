# Virtual Exim 2
## Optional: Caching DNS daemon to use with DNSBL

In order to make use of DNSBL you mostly need your own caching dns server in order to have now issues with rate limits for free usage.
If you are hosting within a datacenter with other customers, your povider might provide you with an dns server. Because this dns server is shared for all customers, the rate limit get exhausted rapidly.

To install you own caching dns server install the following package (on Ubuntu, names on other distributions may differ):
```
sudo apt-get install bind9 
```

If you want your dns server to log things, you need to create the directory by yourself (normally dns is a very silent thing)
Hint: You may change the name of the directory but be sure to change the configuration file to the same directory
```
sudo mkdir /var/log/named
sudo chown bind:bind /var/log/named
```

Now copy the named.conf.options file from this directory to /etc/bind 

Restart your DNS server
```
sudo /etc/init.d/bind9 restart
```

Last this is to update your */etc/resolv.conf*.
Ensure that only your own dns server is listed, multiple entries are used round robin
Example:
```
nameserver 127.0.0.1
#nameserver <ipv6::goes:here>
```

If you want to use IPv6, uncomment the second line and enter your local IPv6 address.

To check if everything is working use the following commands:

For IPv4:
```
host ipv4.google.com
nslookup ipv4.google.com
```

For IPv6:
```
host ipv6.google.com
nslookup ipv6.google.com
```

Sample output for comparison:
```
you@your-server ~ # host ipv4.google.com
ipv4.google.com is an alias for ipv4.l.google.com.
ipv4.l.google.com has address 216.58.214.142
root@your-server ~ # nslookup ipv4.google.com
Server:         127.0.0.1
Address:        127.0.0.1#53

Non-authoritative answer:
ipv4.google.com canonical name = ipv4.l.google.com.
Name:   ipv4.l.google.com
Address: 216.58.214.142

you@your-server ~ # host ipv6.google.com
ipv6.google.com is an alias for ipv6.l.google.com.
ipv6.l.google.com has IPv6 address 2a00:1450:4001:813::200e
you@your-server ~ # nslookup ipv6.google.com
Server:         127.0.0.1
Address:        127.0.0.1#53

Non-authoritative answer:
ipv6.google.com canonical name = ipv6.l.google.com.
```







