class TuftsAudio < TuftsBase
  def self.to_class_uri
    'info:fedora/cm:Audio'
  end

  has_file_datastream 'ACCESS_MP3', control_group: 'E'
  has_file_datastream 'ARCHIVAL_SOUND', control_group: 'E'

end

