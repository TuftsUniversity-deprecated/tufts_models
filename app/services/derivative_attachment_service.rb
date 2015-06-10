module DerivativeAttachmentService
  def self.attach(object, dsid, remote_url, mime_type)
    object.datastreams[dsid].tap do |ds|
      ds.dsLocation = remote_url
      ds.mimeType = mime_type
      ds.checksum = nil
    end
  end
end
