require 'open3'

class VideoGeneratingService
  attr_reader :object, :dsid, :mime_type, :quality

  MP4_OPTIONS = '-vcodec libx264 -pix_fmt yuv420p -vprofile high -preset fast -b:v 500k -maxrate 500k -bufsize 1000k -vf scale=400:trunc\(ow/a/2\)*2 -threads 0 -acodec libvo_aacenc -b:a 128k'

  WEBM_OPTIONS = '-vcodec libvpx -quality good -cpu-used 5 -b:v 500k -maxrate 500k -bufsize 1000k -vf scale=400:trunc\(ow/a/2\)*2 -threads 0 -acodec libvorbis -f webm'

  THUMBNAIL_OPTIONS = "-vframes 1 -r 1 -vf scale=60:trunc\\(ow/a/2\\)*2 -f image2"

  @@ffmpeg_path = 'ffmpeg'

  def initialize(object, dsid, mime_type)
    @object = object
    @dsid = dsid
    @mime_type = mime_type
    @video_path = LocalPathService.new(object, 'Archival.video').local_path
    @output_path_service = LocalPathService.new(object, dsid)
    @output_path = @output_path_service.local_path
  end


  def generate_access_mp4
    DERIVATIVES_LOGGER.info("Converting #{@video_path} to #{@output_path}.")
    transcode_video(MP4_OPTIONS)

  end

  def generate_access_webm
    DERIVATIVES_LOGGER.info("Converting #{@video_path} to #{@output_path}.")
    transcode_video(WEBM_OPTIONS)
  end

  def generate_thumbnail
    DERIVATIVES_LOGGER.info("Converting #{@video_path} to #{@output_path}.")
    transcode_video("-ss #{get_video_half_length} #{THUMBNAIL_OPTIONS}")
  end

  private

  def get_video_length
    result = 2
    success = false

    command = "#{@@ffmpeg_path} -i \"#{@video_path}\"  2>&1 | grep \"Duration\"| cut -d ' ' -f 4 | sed s/,// | sed 's@\\..*@@g' | awk '{ split($1, A, \":\"); split(A[3], B, \".\"); print 3600*A[1] + 60*A[2] + B[1] }'"
    Open3.popen3(command) { |stdin, stdout, stderr, wait_thread|
      stdin.close
      result = stdout.read
      stdout.close
      #error_msg = stderr.read
      stderr.close

      #success = !wait_thread.nil? && wait_thread.value.success?
    }

    result
  end

  def get_video_half_length
    get_video_length.to_i / 2
  end

  def transcode_video(options)
    success = false
    error_msg = ''

    unless File.exist? @video_path
      raise Errno::ENOENT, @video_path
    end

    @output_path_service.make_directory

    unless File.writable?(File.dirname(@output_path))
      raise Errno::EACCES, @output_path
    end

    command = "#{@@ffmpeg_path} -y -i \"#{@video_path}\" #{options} #{@output_path}"

    DERIVATIVES_LOGGER.info("FFMPEG command to execute #{command}")
    Open3.popen3(command) { |stdin, stdout, stderr, wait_thread|
      stdin.close
      stdout.close
      error_msg = stderr.read
      stderr.close

      success = !wait_thread.nil? && wait_thread.value.success?
    }

    if success
      @object.datastreams[dsid].dsLocation = @output_path_service.remote_url
      @object.datastreams[dsid].mimeType = @mime_type
    else
      DERIVATIVES_LOGGER.error("#{$PROGRAM_NAME}: ffmpeg error on command \n #{command} \n #{error_msg}")
    end


    return success
  end


end
