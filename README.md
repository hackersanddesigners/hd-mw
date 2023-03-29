# MediaWiki local dev setup

we use the nix package manager to create a specific environment to run the MediaWiki software. [devenv](https://devenv.sh) is the actual UI program that we use to describe the dev setup and manage it.

we're gonna setup:

- PHP
- a web server (Caddy)
- MySQL (MariaDB)

## setup

first of all, fetch a copy of [MediaWiki](https://www.mediawiki.org/wiki/Download) and put it under a folder named `w` (as per MW instructions):

then: the configuration in `devenv.nix` defines the development environment.

## env variables

copy and rename `env.sample.toml` to `.env.toml` and replace its values from your settings in `w/LocalSettings.php`. for instance:

- db:
  - `name`: `$wgDBname`
  - `schema`: path to a local copy of the MW db to setup its DB schema
  - `user`: `$wgDBuser`
    - the username should be `<name>@localhost`, else the user won't be able to connect to the db; this becasue `$wgDBserver` is set to `localhost`
  - `pw`: `$wgDBpassword`

- web:
  - `localhost`: `$wgServer`

then run:

```
devenv up
```

to start the local server (Caddy), PHP and MySQL processes.

### import db data

open another terminal and do:

- `devenv shell`, to enter to the correct working enviroment defined in `devenv.shell`
- `mysql -u <user>@localhost -p <wikidb> < <path/to/wikidb.sql>`, to do the db import
- `php w/maintenance/update.php` to do the database migration and other things

## todo

- we could manage MediaWiki itself as a git repo
