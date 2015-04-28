class ArchivalStorageService < DatastreamGeneratingService
  attr_reader :object, :dsid, :file

  def initialize(object, dsid, file)
    @object = object
    @dsid = dsid
    @file = file
  end

  def run
    make_directory_for_datastream(dsid)
    File.open(local_path_for(dsid, extension), 'wb') do |f|
      f.write file.read
    end
    object.content_will_update = dsid

    ds = object.datastreams[dsid]
    ds.dsLocation = remote_url_for(dsid, extension)
    ds.mimeType = file.content_type
    Job::CreateDerivatives.create(record_id: pid)
  end

  def extension
    @extension ||= file.original_filename.split('.').last
  end
end
