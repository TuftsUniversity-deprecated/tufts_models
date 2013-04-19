class TuftsImageText < TuftsBase
  has_file_datastream 'Content.html', control_group: 'E'

  has_file_datastream 'Thumbnail.png', control_group: 'E'
  has_file_datastream 'Archival.tif', control_group: 'E'
  has_file_datastream 'Advanced.jpg', control_group: 'E'
  has_file_datastream 'Basic.jpg', control_group: 'E'
  def self.to_class_uri
    'info:fedora/cm:Object.Generic'
  end
end
