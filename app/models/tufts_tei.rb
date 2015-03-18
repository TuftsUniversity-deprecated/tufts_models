class TuftsTEI < TuftsBase

  has_file_datastream "Archival.xml", control_group: 'E', original: true

  def self.to_class_uri
    'info:fedora/cm:Text.TEI'
  end

end