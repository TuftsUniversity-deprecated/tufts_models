In order to use tufts\_models you must insure you use the provided solr configuration in `solr\_conf`.  This has an autocommit directive which ensures the soft-commits used by ActiveFedora are persisted to disk.

Add the following to `app/models/solr_document.rb`


```ruby
  include Tufts::SolrDocument
```


You must have a config/application.yml file.

## Running the tests

You must download and start jetty:

```
rake jetty:unzip jetty:config_solr jetty:start
```

Then set up the test app:

```
rake engine_cart:generate
```
