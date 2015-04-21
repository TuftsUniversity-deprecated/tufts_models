require 'open3'
class TuftsAudio < TuftsBase
  has_file_datastream 'ARCHIVAL_XML', control_group: 'E', original: true
  has_file_datastream 'ARCHIVAL_WAV', control_group: 'E', original: true
  has_file_datastream 'ACCESS_MP3', control_group: 'E'

  def create_derivatives
    make_directory_for_datastream('ACCESS_MP3')
    # Local path should be able to use the extension from the dsLocation.
    input_file = local_path_for('ARCHIVAL_WAV')
    output_path = local_path_for('ACCESS_MP3', 'mp3')

    encode_mp3(input_file, output_path)

    # passing the extension is not necessary, so just plassing mime_type as a placeholder for that.
    datastreams['ACCESS_MP3'].dsLocation = remote_url_for('ACCESS_MP3', 'mp3')
    datastreams['ACCESS_MP3'].mimeType = 'audio/mpeg' 
    output_path

  end

  def self.to_class_uri
    'info:fedora/cm:Audio'
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

  # @param [String] dsid Datastream id
  # @param [String] type the content type to test
  # @return [Boolean] true if type is a valid mime type for audio when dsid == 'ARCHIVAL_WAV' or an xml type when dsid == 'ARCHIVAL_XML'
  def valid_type_for_datastream?(dsid, type)
    case dsid
    when 'ARCHIVAL_WAV'
      %Q{audio/wav audio/x-wav audio/wave audio/mpeg audio/x-mpeg audio/mp3 audio/x-mp3 audio/mpeg3 audio/x-mpeg3 audio/mpg audio/x-mpg audio/x-mpegaudio}.include?(type)
    when 'ARCHIVAL_XML'
      %Q{text/xml application/xml application/x-xml}.include?(type)
    else
      false
    end
  end
end
