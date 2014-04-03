class BatchXmlImport < Batch
  mount_uploader :metadata_file, MetadataFileUploader

  validates :metadata_file, presence: true

  def display_name
    "Xml Import"
  end
end
