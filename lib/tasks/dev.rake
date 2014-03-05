
desc 'Seed data for dev environment'
task 'db:dev:seed' => :environment do
  require File.join(Rails.root, 'db', 'dev_seeds.rb')
end

