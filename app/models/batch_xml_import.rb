require 'import_export/metadata_xml_parser'

class BatchXmlImport < Batch
  mount_uploader :metadata_file, MetadataFileUploader

  validates :metadata_file, presence: true
  validate :metadata_file_must_be_valid

  def display_name
    "Xml Import"
  end

  private

  def metadata_file_must_be_valid
    MetadataXmlParser.validate(metadata_file.read).each do |error|
      errors.add(:base, error.message)
    end
  end
end
