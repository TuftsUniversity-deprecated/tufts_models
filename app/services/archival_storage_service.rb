class ArchivalStorageService < DatastreamGeneratingService
  attr_reader :object, :dsid, :file

  def initialize(object, dsid, file)
    @object = object
    @dsid = dsid
    @file = file
  end

  def run
    path_service = LocalPathService.new(object, dsid, extension)
    path_service.make_directory
    File.open(path_service.local_path, 'wb') do |f|
      f.write file.read
    end
    object.content_will_update = dsid

    ds = object.datastreams[dsid]
    ds.dsLocation = path_service.remote_url
    ds.mimeType = file.content_type
    # TODO seems like there ought to be a save here if we're going to kick of a derivatives job.
    Job::CreateDerivatives.create(record_id: object.pid)
  end

  def extension
    @extension ||= file.original_filename.split('.').last
  end
end
