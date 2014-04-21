require 'import_export/metadata_xml_parser'

class BatchXmlImport < Batch
  mount_uploader :metadata_file, MetadataFileUploader

  validates :metadata_file, presence: true
  validate :metadata_file_must_be_valid

  serialize :uploaded_files

  def display_name
    "Xml Import"
  end

  def pids=(*args)
    raise NotImplementedError.new("Use uploaded files to set the pids for batch uploads.")
  end

  def pids
    (uploaded_files || {}).values
  end

  private

  def metadata_file_must_be_valid
    if metadata_file_changed?
      MetadataXmlParser.validate(metadata_file.read).each do |error|
        errors.add(:base, error.message)
      end
    end
  end
end
