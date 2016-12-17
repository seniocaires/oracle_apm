Install docker
```shell
curl -sSL https://get.docker.com | sh
```

Build image
```shell
docker build -t oracle_apm .
```

Run container
```shell
docker run --rm -p 8080:8080 -it oracle_apm
```
