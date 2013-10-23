namespace :import do

  desc 'Import deposit types from a CSV file'
  task :deposit_types, [:import_file] => :environment do |t, args|
    if confirmation_prompt
      require 'import_export/deposit_type_importer'
      puts "Importing deposit types from file: #{args[:import_file]}"
      importer = DepositTypeImporter.new(args[:import_file])
      importer.import_from_csv
      puts "Import finished"
    else
      puts "Import aborted"
    end
  end

  def confirmation_prompt
    tdt = TuftsDepositType.all.map(&:display_name)
    return true if tdt.empty?

    puts '-------------------------------------------------------------------'
    puts 'The table tufts_deposit_types currently contains entries for: '
    puts tdt.inspect
    puts "\nThis script will import data into the tufts_deposit_types table."
    puts 'It may overwrite existing data.'
    puts 'Do you wish to continue?  (Anything other than "yes" will abort)'

    response = STDIN.gets.chomp
    response == 'yes' ? true : false
  end
end


namespace :export do

  desc 'Export deposit types to a CSV file'
  task :deposit_types, [:export_dir] => :environment do |t, args|
    require 'import_export/deposit_type_exporter'
    exporter = DepositTypeExporter.new(args[:export_dir])
    puts "Exporting deposit types to: #{exporter.export_dir}"
    exporter.export_to_csv
    puts "Export finished: #{exporter.filename}"
  end

end
