class TuftsAudioText < TuftsBase 
  has_file_datastream 'ARCHIVAL_XML', control_group: 'E', original: true
  has_file_datastream 'ARCHIVAL_WAV', control_group: 'E', original: true
  has_file_datastream 'ACCESS_MP3', control_group: 'E'
  has_file_datastream 'PRESENT_SMIL', control_group: 'E'

  def self.to_class_uri
    'info:fedora/cm:Audio.OralHistory'
  end

  # Given a datastream name, return the local path where the file can be found.
  # @example
  #   obj.file_path('ARCHIVAL_XML', 'tif')
  #   # => /local_object_store/data01/tufts/central/dca/MS054/archival_xml/MS054.003.DO.02108.archival.tif
  def file_path(name, extension = nil)
    case name
    when 'ARCHIVAL_WAV', 'ARCHIVAL_XML'
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
end
