## cf_ech.sh

This script is used to turn ech on CloudFlare via cli. 
You have to set `CF_API_TOKEN` and `CF_ZONE_ID` in *cf.env*.

Don't forget to change file permissions:

```sh
chmod 600 ./cf.env
```

```sh
Usage: ./cf_ech.sh on|off
```

## fastly.vcl

This file contains configuration of Varnish to pass XHTTP through it.
You have to set it in VCL snippets.
