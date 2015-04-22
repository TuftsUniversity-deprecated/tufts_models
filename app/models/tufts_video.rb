class TuftsVideo < TuftsBase
  include DraftVersion

  has_file_datastream 'ARCHIVAL_XML', control_group: 'E', original: true
  has_file_datastream 'Archival.video', control_group: 'E', original: true
  has_file_datastream 'Thumbnail.png', control_group: 'E'
  has_file_datastream 'Access.webm', control_group: 'E'
  has_file_datastream 'Access.mp4', control_group: 'E'

  def file_path(name, extension = nil)
    case name
      when 'Thumbnail.png', 'ARCHIVAL_XML', 'Archival.video', 'Access.webm', 'Access.mp4'
        if self.datastreams[name].dsLocation
          self.datastreams[name].dsLocation.sub(Settings.trim_bucket_url + '/' + object_store_path, "")
        else
          raise ArgumentError, "Extension required for #{name}" unless extension
          File.join(directory_for(name), "#{pid_without_namespace}.archival.#{extension}")
        end
      else
        File.join(directory_for(name), "#{pid_without_namespace}.#{name.downcase.sub('_', '.')}")
    end
  end

  # @param [String] dsid Datastream id
  # @param [String] type the content type to test
  # @return [Boolean] true if type is a valid mime type for audio when dsid == 'ARCHIVAL_WAV' or an xml type when dsid == 'ARCHIVAL_XML'
  def valid_type_for_datastream?(dsid, type)
    case dsid
      when 'Archival.video'
        %Q{video/mp4, video/ogg, video/webm, video/avi}.include?(type)
      when 'ARCHIVAL_XML'
        %Q{text/xml application/xml application/x-xml}.include?(type)
      else
        false
    end
  end
end
