source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '3.2.13'

gem 'sqlite3'

gem 'hydra-head'
gem 'hydra-role-management', '0.0.2'
gem 'active-fedora', '6.4.0.rc1'
gem 'hydra-editor', '0.0.3' 

gem 'disable_assets_logger', :group => :development

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-rails'
  gem "jquery-fileupload-rails"
  gem "bootstrap-sass"
end

gem "devise"
gem 'bootstrap_forms'
gem 'rmagick', '2.13.2', require: 'RMagick'
gem 'resque'

group :development do
  gem 'unicorn'
  gem 'jettywrapper'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'launchy'
  gem 'factory_girl_rails'
end

gem 'chronic' # for lib/tufts/model_methods.rb
gem 'titleize' # for lib/tufts/model_methods.rb
gem 'settingslogic' # for settings
