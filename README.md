# EDGY
backdoors
* [berabou.me](https://github.com/59naga/berabou.me/)
* [static.edgy.black](http://static.edgy.black/)
* [edgy.black](https://github.com/59naga/edgy.black/)

# Backing up
```bash
$ npm run backup
$ exit
$ scp edgy:edgy/backups/$(date '+%Y%m%d-%H')* .
```
## Rollbacking the docker-mysql(for develop)
```bash
$ cd edgy.black/..
$ unzip ******-******.zip -o
$ docker exec -i edgy.black mysql edgy_test < edgy.black.sql
```

v0.0.3 Sat Mar 19 2015
=========================
* [`fd11bae`][1] :bug: Fix: Cannot read property 'indexOf' of undefined
* [`c4b17c3`][2] :bug: Fix: Always 403 at deploy
* [`unknown`][3] :bug: Fix q.all -> q.allSettled
* [`unknown`][4] :bug: Fix `Error: listen EADDRINUSE` due to travis.edgy.black>deploy
* [`unknown`][4] :racehorse: Add `NODE_ENV: production` for Enable view cache

[1]: https://github.com/59naga/edgy/commit/fd11bae6a50ad2237722f787077b30586152c844
[2]: https://github.com/59naga/edgy/commit/c4b17c3c2d9ae8250a3b2e5791075337ec4b687b
[3]: https://github.com/59naga/edgy/commits/master
[4]: https://github.com/59naga/edgy/commits/master

License
=========================
MIT by 59naga

[0]: https://github.com/59naga/edgy/commits/master
