# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

def clean_up_carrierwave_files
  # FileUtils.rm_rf(CarrierWave::Uploader::Base.root)
end

require 'factory_girl'
require 'tufts_models'
require 'engine_cart'
EngineCart.load_application!


FactoryGirl.definition_file_paths = [File.expand_path("../factories", __FILE__)]
FactoryGirl.find_definitions


COLLECTION_ERROR_LOG = ActiveSupport::Logger.new(File.expand_path("../internal/log/collection_facet_error.log", __FILE__))

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  
  # config.fixture_path = File.expand_path("../fixtures", __FILE__)
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  config.before(:suite) do
    User.destroy_all
    clean_fedora_and_solr
  end

  config.after(:suite) do
    clean_fedora_and_solr
    clean_up_carrierwave_files
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #
  config.order = "random"
end

def find_or_create_ead(pid)
  if TuftsEAD.exists?(pid)
    TuftsEAD.find(pid)
  else
    TuftsEAD.create!(pid: pid, title: "Test #{pid}", displays: ['dl'])
  end
end

def clean_fedora_and_solr
  ActiveFedora::Base.delete_all
  solr = ActiveFedora::SolrService.instance.conn
  solr.delete_by_query("*:*", params: { commit: true })
end

