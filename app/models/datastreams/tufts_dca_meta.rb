class TuftsDcaMeta < ActiveFedora::OmDatastream

  # 2012-01-23 decided to make everything searchable here and handle facetable in the to_solr methods of the
  # models

  set_terminology do |t|
    t.root("path" => "dc", "xmlns" => "http://purl.org/dc/elements/1.1/",
           "xmlns:dca_dc" => "http://nils.lib.tufts.edu/dca_dc/",
           "xmlns:dcadec" => "http://nils.lib.tufts.edu/dcadesc/",
           "xmlns:dcatech" => "http://nils.lib.tufts.edu/dcatech/",
           "xmlns:xlink" => "http://www.w3.org/1999/xlink")
    t.title(:index_as => :stored_searchable)
    t.creator(:index_as => :stored_searchable)
    t.source(:path => "source", :index_as => :stored_searchable)
    t.description(:index_as => :stored_searchable)
    t.date_created(:path => "date.created", :index_as => :stored_searchable)
    t.date_available(:path => "date.available", :index_as => :stored_searchable)
    t.date_issued(:path => "date.issued", :index_as => :stored_searchable)
    t.identifier(:index_as => :stored_searchable)
    t.rights(:index_as => :stored_searchable)
    t.bibliographic_citation(:path => "bibliographicCitation", :index_as => :stored_searchable)
    t.publisher(:index_as => :stored_searchable)
    t.type(:index_as => :stored_searchable)
    t.format(:index_as => :stored_searchable)
    t.extent(:index_as => :stored_searchable)
    t.persname(:namespace_prefix => "dcadesc", :index_as => :stored_searchable)
    t.corpname(:namespace_prefix => "dcadesc", :index_as => :stored_searchable)
    t.geogname(:namespace_prefix => "dcadesc", :index_as => :stored_searchable)
    t.genre(:namespace_prefix => "dcadesc",  :index_as => :stored_searchable)
    t.subject(:namespace_prefix => "dcadesc", :index_as => :stored_searchable)
    t.funder(:namespace_prefix => "dcadesc", :index_as => :stored_searchable)
    t.temporal(:index_as => :stored_searchable)
    t.resolution(:namespace_prefix => "dcatech", :index_as => :stored_searchable)
    t.bitdepth(:namespace_prefix => "dcatech", :index_as => :stored_searchable)
    t.colorspace(:namespace_prefix => "dcatech", :index_as => :stored_searchable)
    t.filesize(:namespace_prefix => "dcatech", :index_as => :stored_searchable)
  end

  # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
  # I thought my confusion here was in what OM was doing but its actually a lack of knowledge
  # in how Nokogiri works.
  # see here for more details:
  # http://nokogiri.org/Nokogiri/XML/Builder.html
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.dc(:version => "0.1", :xmlns => "http://purl.org/dc/elements/1.1/",
             "xmlns:dcadesc" => "http://nils.lib.tufts.edu/dcadesc/",
             "xmlns:dcatech" => "http://nils.lib.tufts.edu/dcatech/",
             "xmlns:xlink" => "http://www.w3.org/1999/xlink")
    end

    builder.doc
  end
end
