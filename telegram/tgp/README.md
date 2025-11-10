## tgp

By default telegram proxy is set to `tg` subdomain.
You have to generate secret for the proxy:

```sh
./generate.sh tg.example.org
```

Then set variables in *config.toml* file:

```toml
secret = "SOME_SECRET"
host = "tg.example.org:443"
```
