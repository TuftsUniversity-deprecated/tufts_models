Add the following to `app/models/solr_document.rb`


```ruby
  include Tufts::SolrDocument
```


You must have a config/application.yml file.

## Running the tests

First, set up the test app

```
rake engine_cart:generate
```
