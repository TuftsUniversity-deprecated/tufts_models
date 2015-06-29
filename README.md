[![Build Status](https://travis-ci.org/curationexperts/tufts_models.svg)](https://travis-ci.org/curationexperts/tufts_models)

In order to use tufts\_models you must insure you use the provided solr configuration in `solr\_conf`.  This has an autocommit directive which ensures the soft-commits used by ActiveFedora are persisted to disk.

Add the following to `app/models/solr_document.rb`


```ruby
  include Tufts::SolrDocument
```

You must have a config/application.yml file.

In your rails app, you'll need to configure the front-ends that records can be displayed in.
Using spec/test_app_templates/displays.yml as an example, create a file in your rails app called config/authorities/displays.yml

Run `rails g qa:install` to configure the routes for QA.

## Running the tests

You must download and start jetty:

```
rake jetty:unzip jetty:config_solr jetty:start
```

Then set up the test app:

```
rake engine_cart:generate
```
