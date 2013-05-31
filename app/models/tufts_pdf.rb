class TuftsPdf < TuftsBase
  has_file_datastream 'Archival.pdf', control_group: 'E', original: true

  # @param [String] dsid Datastream id
  # @param [String] type the content type to test
  # @return [Boolean] true if type is a valid mime type for pdf
  def valid_type_for_datastream?(dsid, type)
    %Q{application/pdf application/x-pdf application/acrobat applications/vnd.pdf text/pdf text/x-pdf}.include?(type)
  end

  def self.to_class_uri
    'info:fedora/cm:Text.PDF'
  end
end
