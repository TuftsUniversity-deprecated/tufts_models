require 'jettywrapper'

task :fixtures => :environment do
  FIXTURES = %w(tufts:WP0001
    tufts:UA069.001.DO.UP029
    tufts:UA069.005.DO.00272
    tufts:UA069.005.DO.00239
    tufts:UA069.005.DO.00339
    tufts:UP022.001.001.00001.00003
    tufts:UP022.001.001.00001.00004 
    tufts:UP022.001.001.00001.00005
    tufts:UP029.003.003.00014 
    tufts:UP029.003.003.00012
    tufts:UP029.020.031.00108 
    )
  loader = ActiveFedora::FixtureLoader.new("#{Rails.root}/spec/fixtures")
  FIXTURES.each do |pid|
    puts("Refreshing #{pid}")
    ActiveFedora::FixtureLoader.delete(pid)
    loader.import_and_index(pid)

    # ENV["pid"] = fixture        
    # Rake::Task["repo:delete"].reenable
    # Rake::Task["repo:delete"].invoke
    # Rake::Task["narm:fixtures:import"].reenable
    # Rake::Task["narm:fixtures:import"].invoke
  end
end

task :ci => :jetty do
  Jettywrapper.wrap(Jettywrapper.load_config) do
    Rake::Task['spec'].invoke
  end
end


task :jetty do
  unless File.exist?('jetty')
    puts "Downloading jetty"
    `rails generate hydra:jetty`
  end
end

