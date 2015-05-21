require 'carrierwave'
require 'carrierwave/orm/activerecord'

class BatchXmlImport < Batch
  mount_uploader :metadata_file, MetadataFileUploader

  validates :metadata_file, presence: true
  validate :metadata_file_must_be_valid

  has_many :uploaded_files, foreign_key: 'batch_id'

  attr_writer :parser_class

  def parser
    @parser ||= (@parser_class || 'MetadataXmlParser').constantize.new(metadata_file.read)
  end

  def display_name
    "Xml Import"
  end

  def missing_files
    parser.filenames - uploaded_files.map(&:filename)
  end

  def pids=(*args)
    raise NotImplementedError.new("Use uploaded files to set the pids for batch uploads.")
  end

  def pids
    uploaded_files.map(&:pid)
  end

  private

  def metadata_file_must_be_valid
    if metadata_file_changed? && parser
      parser.validate.each do |error|
        errors.add(:base, error.message)
      end
    end
  end
end
