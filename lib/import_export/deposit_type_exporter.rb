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
      column_names = DepositTypeExporter.columns_to_include_in_export
      csv << column_names
      types_to_export = DepositType.all.sort{|a,b| a.display_name <=> b.display_name }
      types_to_export.each do |type|
        csv << column_names.map{|col_name| type.send(col_name)}
      end
    end

    Rails.logger.info "Finished exporting Deposit Types"
  end

  def create_export_dir
    FileUtils.mkdir_p(@export_dir)
  end

  def self.columns_to_include_in_export
    ["display_name", "deposit_view", "license_name", "deposit_agreement"]
  end

end
