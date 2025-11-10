## tgp

By default telegram proxy is set to `tg` subdomain.
You have to generate secret for the proxy:

```sh
./generate.sh tg.example.org
```

You will get something like this:

```sh
[*] config secret: eebf8331bfea3fcbc117a14ab77d961edb74672e6578616d706c652e6f7267
[*] proxy url:     tg://proxy?server=tg.example.org&port=443&secret=7r-DMb_qP8vBF6FKt32WHtt0Zy5leGFtcGxlLm9yZw
```

Then set variables in *config.toml* file:

```toml
secret = "SOME_SECRET"
host = "tg.example.org:443"
```

Run docker container:

```sh
docker compose up -d
```
