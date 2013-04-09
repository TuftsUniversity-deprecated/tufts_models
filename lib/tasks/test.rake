require 'jettywrapper'


task :ci => :jetty do
  Jettywrapper.wrap(Jettywrapper.load_config) do
    Rake::Task['db:test:prepare'].invoke
    Rake::Task['spec'].invoke
  end
end


task :jetty do
  unless File.exist?('jetty')
    puts "Downloading jetty"
    `rails generate hydra:jetty`
  end
end

