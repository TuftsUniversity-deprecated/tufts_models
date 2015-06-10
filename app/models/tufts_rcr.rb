class TuftsRCR < TuftsBase
  has_file_datastream 'RCR-CONTENT', control_group: 'E', versionable: false, default: true

  def self.to_class_uri
    'info:fedora/cm:Text.RCR'
  end

end
