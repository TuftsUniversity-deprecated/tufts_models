class TuftsVideo < TuftsBase

  has_file_datastream 'ARCHIVAL_XML', control_group: 'E', original: true
  has_file_datastream 'Archival.video', control_group: 'E', original: true
  has_file_datastream 'Thumbnail.png', control_group: 'E'
  has_file_datastream 'Access.webm', control_group: 'E'
  has_file_datastream 'Access.mp4', control_group: 'E'

  # @param [String] dsid Datastream id
  # @param [String] type the content type to test
  # @return [Boolean] true if type is a valid mime type for audio when dsid == 'ARCHIVAL_WAV' or an xml type when dsid == 'ARCHIVAL_XML'
  def valid_type_for_datastream?(dsid, type)
    case dsid
    when 'Archival.video'
      %w(video/mp4 video/ogg video/webm video/avi).include?(type)
    when 'ARCHIVAL_XML'
      %w(text/xml application/xml application/x-xml).include?(type)
    else
      false
    end
  end

  def create_derivatives
    create_access_webm
    create_access_mp4
    create_thumbnail
  end

  def create_access_webm
    VideoGeneratingService.new(self, 'Access.webm', 'video/webm').generate_access_webm
  end

  def create_access_mp4
    VideoGeneratingService.new(self, 'Access.mp4', 'video/mp4').generate_access_mp4
  end

  def create_thumbnail
    VideoGeneratingService.new(self, 'Thumbnail.png', 'image/png').generate_thumbnail
  end
end
