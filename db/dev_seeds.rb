
unless Rails.env == 'development'
  raise "Non-development environment: Aborting test data seeding"
end

puts "Creating EAD objects:"

sources = ['UA015', 'UA005', 'PB', 'UA071']
sources.each do |source|
  pid = "tufts:UA069.001.DO.#{source}"
  if TuftsEAD.exists?(pid)
    puts "    Object #{source} already exists"
  else
    puts "    Creating object #{source}"
    TuftsEAD.create!(pid: pid, title: "EAD #{source}")
  end
end

