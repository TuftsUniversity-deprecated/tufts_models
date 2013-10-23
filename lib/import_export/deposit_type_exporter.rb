class DepositTypeExporter
  DEFAULT_EXPORT_DIR = File.join(Rails.root, 'tmp', 'export')

  attr_reader :export_dir, :filename

  def initialize(export_dir=DEFAULT_EXPORT_DIR, filename=nil)
    @export_dir = export_dir
    @filename = filename || default_filename
  end

  def default_filename
    time = Time.now.strftime("%Y_%m_%d_%H%M%S")
    "deposit_type_export_#{time}.csv"
  end

  def export_to_csv
    create_export_dir
    export_file = File.join(@export_dir, @filename)

    Rails.logger.info "Exporting Deposit Types: #{export_file}"

    CSV.open(export_file, "w") do |csv|
      csv << columns_to_include_in_export
      types = TuftsDepositType.all.sort{|a,b| a.display_name <=> b.display_name }
      types.each do |type|
        csv << [type.display_name, type.deposit_agreement]
      end
    end

    Rails.logger.info "Finished exporting Deposit Types"
  end

  def create_export_dir
    FileUtils.mkdir_p(@export_dir)
  end

  def columns_to_include_in_export
    ["display_name", "deposit_agreement"]
  end

end
