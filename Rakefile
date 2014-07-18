begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'jettywrapper'

require 'engine_cart/rake_task'
desc "Run the ci build"
task ci: ['engine_cart:generate', 'jetty:clean', 'jetty:config_solr'] do
  ENV['environment'] = "test"
  jetty_params = Jettywrapper.load_config
  jetty_params[:startup_wait]= 90

  Jettywrapper.wrap(jetty_params) do
    # run the tests
    Rake::Task["spec"].invoke
  end
end

namespace :jetty do
  desc "Configure solr"
  task :config_solr do
    FileList['solr_conf/conf/*'].each do |f|  
      cp("#{f}", 'jetty/solr/development-core/conf/', :verbose => true)
      cp("#{f}", 'jetty/solr/test-core/conf/', :verbose => true)
    end
  end
end



task default: :ci
