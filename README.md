#Tufts Hydra Admin

[![Build Status](https://travis-ci.org/curationexperts/tufts.png?branch=master)](https://travis-ci.org/curationexperts/tufts)

##Initial Setup

### Prerequisites
* [ImageMagick](http://www.imagemagick.org/)
* [ffmpeg](http://www.ffmpeg.org/)

**Note:**
If you install ImageMagick using homebrew, you may need to add a switch for libtiff:

```bash
$ brew install imagemagick --with-libtiff
```

Or else you may get errors like this when you run the specs:  
"Magick::ImageMagickError: no decode delegate for this image format (something.tif)"

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
$ rake jetty:config
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
