$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tufts_models/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tufts_models"
  s.version     = TuftsModels::VERSION
  s.authors     = ["Justin Coyne"]
  s.email       = ["justin@curationexperts.com"]
  s.homepage    = "https://github.com/curationexperts/tufts_models"
  s.summary     = "Hydra models for Tufts library"
  s.description = "Hydra models for Tufts library"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})


  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "engine_cart"
  s.add_development_dependency "devise", "< 3.3.0"

  s.add_dependency "railties", ">= 3.2", '< 5'
  s.add_dependency "active-fedora", "~> 7.0"
  s.add_dependency "chronic"
  s.add_dependency "hydra-core"
  s.add_dependency "hydra-role-management"
  s.add_dependency "titleize"
  s.add_dependency "settingslogic"
  s.add_dependency "resque-status"
  s.add_dependency "carrierwave"
  s.add_dependency "hydra-editor"
  s.add_dependency "rmagick", '2.13.2'
end
