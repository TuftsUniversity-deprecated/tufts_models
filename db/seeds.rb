# ruby encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'import_export/deposit_type_importer'

puts "Begin loading seed data"

puts "Loading Roles:"
roles = ["admin"]

roles.each do | name |
  puts "  #{name}"
  Role.first_or_create(name: name)
end

deposit_types_file = File.join(Rails.root, 'db', 'fixtures', 'deposit_types.csv')
puts "Loading Deposit Types from #{deposit_types_file}"
DepositTypeImporter.new(deposit_types_file).import_from_csv

puts "Data seeding finished"
