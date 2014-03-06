# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  
  config.include Devise::TestHelpers, :type => :controller
  
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  config.before(:suite) { User.destroy_all}

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #
  config.order = "random"

  config.before(:all) do
    clean_fedora_and_solr
  end

  config.after(:all) do
    clean_fedora_and_solr
  end

end

def find_or_create_ead(pid)
  if TuftsEAD.exists?(pid)
    TuftsEAD.find(pid)
  else
    TuftsEAD.create!(pid: pid, title: "Test #{pid}")
  end
end

def clean_fedora_and_solr
  ActiveFedora::Base.delete_all
  solr = ActiveFedora::SolrService.instance.conn
  solr.delete_by_query("*:*", params: { commit: true })
end

