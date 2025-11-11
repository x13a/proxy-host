# proxy-host

Proxy behind CDN bootstrap

You must have a server and domain name for this.

## Usage

Clone repository to local directory:

```sh
git clone https://github.com/x13a/proxy-host
```

Change directory to recently clonned repository:

```sh
cd proxy-host
```

Run *setup.sh* file:

```sh
./setup.sh
```

Now you have configure DNS records.  
Caddy is set to use following subdomains:

```sh
# CDN origin, direct connection, token protected
ORIGIN_SUBDOMAIN=origin
# CDN, token protected
CLOUDFLARE_SUBDOMAIN=cloudflare
# ip lookup, direct connection
IP_SUBDOMAIN=ip
# disabled by default, direct connection, will be sig-aabbccdd
SIGNAL_PROXY_SUBDOMAIN=sig
# disabled by default, direct connection, will be tg-aabbccdd
TELEGRAM_PROXY_SUBDOMAIN=tg

# redir to your domain
# default CDN, token protected
# www
```

CDN has to set request header to be able to connect.  
*X-Auth-Token* is used for this.

## License

MIT
