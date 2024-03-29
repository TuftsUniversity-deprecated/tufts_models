# Given an object and a dsid, tell us the local path for finding that file
class LocalPathService
  attr_reader :object, :dsid, :extension

  def initialize(object, dsid, extension=nil)
    @object = object
    @dsid = dsid
    @extension = extension
  end

  def local_path
    if object.datastreams[dsid] && object.datastreams[dsid].dsLocation
      object.datastreams[dsid].dsLocation.sub(Settings.trim_bucket_url, Settings.object_store_root)
    else
      File.join(local_path_root, object.file_path(dsid, extension))
    end
  end

  def make_directory
    dir = File.join(local_path_root, object.directory_for(dsid))
    FileUtils.mkdir_p(dir) unless Dir.exists?(dir)
  end

  def remote_url
    # if its already defined in a previous version keep it the same
    # there were a few cases where this returned nil, and so it whould fail
    # in those cases.  we noticed these in MIRA-49 where an aborted
    # ingest, continued later may result in a nil value.
    if object.datastreams[dsid] && object.datastreams[dsid].dsLocation
      object.datastreams[dsid].dsLocation
    else
      File.join(remote_root, object.file_path(dsid, extension))
    end
  end

  private

    def remote_root
      File.join(Settings.trim_bucket_url, object_store_path)
    end

    def local_path_root
      File.join(Settings.object_store_root, object_store_path)
    end

    # return the compontent of the path/url that is common in the remote URL
    # and on the filesystem.
    def object_store_path
      if PidUtils.autogenerated?(object.pid)
        File.join(Settings.object_store_base, Settings.object_store_tisch)
      else
        File.join(Settings.object_store_base, Settings.object_store_dca)
      end
    end
end
