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
$ cp config/devise.yml.sample config/devise.yml
!!! Important. Open config/devise.yml and generate a new id

$ rake db:schema:load
$ rake db:seed
$ rails g hydra:jetty
$ rake jetty:config
```

##Configure Authentication services
The application includes a basic devise implementation for user management and authentication.  Integrating the 
application with your local authentication system is beyone the scope of this document; please consult the 
relevant devise documentation.

If you wish to supply a specific format for the text used in displaying user names, please modify the display_name 
method on the user model:
```
# app/models/user.rb

class User < ActiveRecord::Base
...
  def display_name   #update this method to return the string you would like used for the user name stored in fedora objects.
    self.user_key 
  end
....
end

```

##Start background workers

```bash
$ QUEUE=* rake resque:work
```

## Start hydra-jetty
```bash
$ rake jetty:start
```

## Start redis
```bash
redis-server
```

```bash
$ rails s
```

## Loading Data

### Load some fixture data into your dev environment

Make sure jetty is running, then run the rake task:

```bash
rake fixtures
```

### Importing deposit types from a CSV file

The CSV file is expected to have the headers:  
` display_name,deposit_agreement `

```bash
$ rake import:deposit_types['/absolute/path/to/import/file.csv']
```

### Exporting deposit types to a CSV file

The exporter will create a CSV file that contains data from the `deposit_types` table.

```bash
$ rake export:deposit_types['/absolute/path/to/export/dir']
```

You can also export the deposit types data through the UI if you log into the app as an admin user.

