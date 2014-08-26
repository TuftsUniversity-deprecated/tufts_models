class DcaAdmin < ActiveFedora::OmDatastream
  set_terminology do |t|
    t.root(:path => "admin", 'xmlns:local'=>"http://nils.lib.tufts.edu/dcaadmin/", 'xmlns:ac'=>"http://purl.org/dc/dcmitype/")

    t.template_name index_as: :stored_searchable, path: 'templateName'
    t.steward namespace_prefix: "local", index_as: :stored_searchable
    t.name namespace_prefix: "ac", index_as: :stored_searchable
    t.comment namespace_prefix: "ac", index_as: :stored_searchable
    t.retentionPeriod namespace_prefix: "local", index_as: :stored_searchable
    t.displays namespace_prefix: "local", index_as: [:stored_sortable, :symbol]
    t.embargo namespace_prefix: "local", index_as: :dateable
    t.status namespace_prefix: "local", index_as: :stored_searchable
    t.startDate namespace_prefix: "local", index_as: :stored_searchable
    t.expDate namespace_prefix: "local", index_as: :stored_searchable
    t.qrStatus namespace_prefix: "local", index_as: [:stored_searchable, :facetable]
    t.rejectionReason namespace_prefix: "local", index_as: :stored_searchable
    t.note namespace_prefix: "local", index_as: :stored_searchable
    t.createdby namespace_prefix: "local"

    t.published_at namespace_prefix: "local", path: "publishedAt", type: :time, index_as: :stored_sortable
    t.edited_at namespace_prefix: "local", path: "editedAt", type: :time, index_as: :stored_sortable
    t.creatordept namespace_prefix: "local"
    t.batch_id namespace_prefix: "local", index_as: :symbol, :path => 'batchID'
  end

  # BUG?  Extra solr fields are generated when there is a default namespace (xmlns) declared on the root.
  #   compared to when the root has a namespace and the child elements do not have an namespace.

  def self.xml_template
    Nokogiri::XML('<admin xmlns:local="http://nils.lib.tufts.edu/dcaadmin/" xmlns:ac="http://purl.org/dc/dcmitype/"/>')
  end

  def prefix
    ""
  end

end
