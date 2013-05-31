require 'open3'
class TuftsAudio < TuftsBase
  def self.to_class_uri
    'info:fedora/cm:Audio'
  end

  has_file_datastream 'ACCESS_MP3', control_group: 'E'
  has_file_datastream 'ARCHIVAL_SOUND', control_group: 'E', original: true


  def create_derivatives
    make_directory_for_datastream('ACCESS_MP3')
    # Local path should be able to use the extension from the dsLocation.
    input_file = local_path_for('ARCHIVAL_SOUND')
    output_path = local_path_for('ACCESS_MP3', 'mp3')

    encode_mp3(input_file, output_path)

    # passing the extension is not necessary, so just plassing mime_type as a placeholder for that.
    datastreams['ACCESS_MP3'].dsLocation = remote_url_for('ACCESS_MP3', 'mp3')
    datastreams['ACCESS_MP3'].mimeType = 'audio/mpeg' 
    output_path

  end

  def encode_mp3(input_file, output_path)
    opts = ""
    if File.extname(input_file) == '.mp3'
      # Don't re-encode, just copy
      FileUtils.cp(input_file, output_path)
    else
      self.class.encode(input_file, output_path) #'mp3', 'audio/mp3', opts)
    end
  end

  def self.encode(input_file, output_file)
    options = '-b:a 192k'
    command = "#{ffmpeg_path} -y -i \"#{input_file}\" #{options} #{output_file}"
    stdin, stdout, stderr, wait_thr = Open3.popen3(command)
    stdin.close
    out = stdout.read
    stdout.close
    err = stderr.read
    stderr.close
    raise "Unable to execute command \"#{command}\"\n#{err}" unless wait_thr.value.success?
  end

  def self.ffmpeg_path
    'ffmpeg'
  end

  # Given a datastream name, return the local path where the file can be found.
  # @example
  #   obj.file_path('Archival.tif', 'tif')
  #   # => /local_object_store/data01/tufts/central/dca/MS054/archival_tif/MS054.003.DO.02108.archival.tif
  def file_path(name, extension = nil)
    case name
    when 'ARCHIVAL_SOUND'
      if self.datastreams[name].dsLocation
        self.datastreams[name].dsLocation.sub(Settings.trim_bucket_url + '/' + object_store_path, "")
      else
        raise ArgumentError, "Extension required for #{name}" unless extension
        File.join(directory_for(name), "#{pid_without_namespace}.archival.#{extension}")
      end
    when 'ACCESS_MP3'
      File.join(directory_for(name), "#{pid_without_namespace}.access.mp3")
    else
      raise ArgumentError, "I don't know about the datastream #{name}"
    end
  end

  # @param [String] dsid Datastream id
  # @param [String] type the content type to test
  # @return [Boolean] true if type is a valid mime type for audio
  def valid_type_for_datastream?(dsid, type)
    %Q{audio/wav audio/x-wav audio/wave audio/mpeg audio/x-mpeg audio/mp3 audio/x-mp3 audio/mpeg3 audio/x-mpeg3 audio/mpg audio/x-mpg audio/x-mpegaudio}.include?(type)
  end
end
