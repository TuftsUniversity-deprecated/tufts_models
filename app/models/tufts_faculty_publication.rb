class TuftsFacultyPublication < TuftsBase 
  has_file_datastream 'Archival.pdf', control_group: 'E', original: true
  def self.to_class_uri
    'info:fedora/cm:Text.FacPub'
  end
end
