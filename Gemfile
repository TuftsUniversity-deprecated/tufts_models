source 'https://rubygems.org'

gemspec 

gem 'active-fedora', github: 'projecthydra/active_fedora', branch: 'feature/active-triples'
gem 'active-triples', github: 'jcoyne/ActiveTriples', branch: 'after_clear'

file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path("../spec/internal", __FILE__))
if File.exists?(file)
  puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(file)
end
