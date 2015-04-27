class FedoraObjectCopyService
  attr_reader :source_pid, :destination_pid, :klass

  def initialize(klass, options = {})
    @klass = klass
    @source_pid = options.fetch(:from)
    @destination_pid = options.fetch(:to)
  end

  def run
    return false unless klass.exists? source_pid

    foxml = api.export(pid: source_pid, context: 'archive')
    api.ingest(file: transmutate_export(foxml))
  end

  private

    def api
      @api ||= ActiveFedora::Base.connection_for_pid(source_pid).api
    end

    # Replace old pid with new pid and strip out the checksums from RELS-EXT & DC
    # RELS-EXT and DC have the pid encoded in them, so changing the pid changes the checksum.
    # The archival.tif datastream has a checksum of "ExceptionReadingStream" because the bucket01 server was unreachable.
    def transmutate_export(foxml)
      remove_checksums(foxml).gsub(source_pid, destination_pid)
    end

    def remove_checksums(foxml)
      ngxml = Nokogiri::XML(foxml)
      ['RELS-EXT', 'DC', 'Archival.tif'].each do |dsid|
        ngxml.search("//foxml:datastream[@ID=\"#{dsid}\"]//foxml:contentDigest", 'foxml'=>"info:fedora/fedora-system:def/foxml#").remove
      end
      ngxml.to_xml
    end
end
