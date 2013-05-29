class DcaAdmin < ActiveFedora::OmDatastream
  set_terminology do |t|
    t.root(:path => "admin", 'xmlns'=>"http://nils.lib.tufts.edu/dcaadmin/", 'xmlns:ac'=>"http://purl.org/dc/dcmitype/")

    t.steward index_as: :stored_searchable
    t.name namespace_prefix: "ac", index_as: :stored_searchable
    t.comment namespace_prefix: "ac", index_as: :stored_searchable
    t.retentionPeriod index_as: :stored_searchable
    t.displays index_as: :stored_sortable
    t.embargo index_as: :stored_searchable
    t.status index_as: :stored_searchable
    t.startDate index_as: :stored_searchable
    t.expDate index_as: :stored_searchable
    t.qrStatus index_as: :stored_searchable
    t.rejectionReason index_as: :stored_searchable
    t.note index_as: :stored_searchable

    t.published_at(:path => "publishedAt", :type=>:time, index_as: :stored_sortable)
    t.edited_at(:path => "editedAt", :type=>:time, index_as: :stored_sortable)
  end

  # BUG?  Extra solr fields are generated when there is a default namespace (xmlns) declared on the root.
  #   compared to when the root has a namespace and the child elements do not have an namespace.
  # BUG?  There's never more than one root node, so why do admin_0_published_at_dtsi  ?

  def self.xml_template
    Nokogiri::XML('<admin xmlns="http://nils.lib.tufts.edu/dcaadmin/" xmlns:ac="http://purl.org/dc/dcmitype/"/>')
  end
end
