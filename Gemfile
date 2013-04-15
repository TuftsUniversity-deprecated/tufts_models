source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'sqlite3'

gem 'fcrepo_admin', github: 'projecthydra/fcrepo-admin'
gem 'hydra-head'
gem 'active-fedora', github: 'projecthydra/active_fedora'
#gem 'hydra-role-management', path: '../hydra-role-management'
gem 'hydra-role-management', github: 'projecthydra/hydra-role-management', ref: '96b0002'
#gem 'hydra-editor', path: '../hydra-editor'
gem 'hydra-editor', github: 'projecthydra/hydra-editor', ref: 'cf87b0c'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-rails'
  gem "bootstrap-sass"
end

gem "devise"
gem 'bootstrap_forms'

group :development do
  gem 'unicorn'
  gem 'jettywrapper'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'factory_girl_rails'
end

gem 'chronic' # for lib/tufts/model_methods.rb
gem 'titleize' # for lib/tufts/model_methods.rb
gem 'settingslogic' # for settings
