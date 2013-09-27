#Tufts Hydra Admin

[![Build Status](https://travis-ci.org/curationexperts/tufts.png?branch=master)](https://travis-ci.org/curationexperts/tufts)

##Initial Setup

```bash
$ bundle install
$ cp config/initializers/secret_token.rb.sample config/initializers/secret_token.rb
!!! Important. Open config/initializer/secret_token.rb and generate a new id
$ cp config/database.yml.sample config/database.yml
$ cp config/solr.yml.sample config/solr.yml
$ cp config/redis.yml.sample config/redis.yml
$ cp config/fedora.yml.sample config/fedora.yml

$ rake db:schema:load
$ rake db:seed
$ rails g hydra:jetty
```

##Start background workers

```bash
$ QUEUE=* rake resque:work
```

## Start hydra-jetty
```bash
$ rake jetty:start
```

```bash
$ rails s
```