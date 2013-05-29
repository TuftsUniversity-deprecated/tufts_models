source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '3.2.13'

gem 'sqlite3'

gem 'fcrepo_admin', '0.3.5'
gem 'hydra-head'
gem 'hydra-role-management', '0.0.2'
gem 'active-fedora', git: 'https://github.com/projecthydra/active_fedora.git', branch: 'delegate_parameters'
gem 'om', git: 'https://github.com/projecthydra/om.git', branch: 'fix_serializing_nil'
gem 'hydra-editor',   git: 'https://github.com/projecthydra/hydra-editor.git', ref: 'bb3ab78'
#gem 'hydra-editor', path: '../hydra-editor'

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
  gem 'factory_girl_rails'
end

gem 'chronic' # for lib/tufts/model_methods.rb
gem 'titleize' # for lib/tufts/model_methods.rb
gem 'settingslogic' # for settings
