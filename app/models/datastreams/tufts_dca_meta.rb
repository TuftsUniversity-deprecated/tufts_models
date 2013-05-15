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
    t.source2(:path => "source", :index_as => :stored_searchable)
    t.description(:index_as => :stored_searchable)
    t.date_created(:path => "date.created", :index_as => :stored_searchable)
    t.date_available(:path => "date.available", :index_as => :stored_searchable)
    t.date_issued(:path => "date.issued", :index_as => :stored_searchable)
    t.identifier(:index_as => :stored_searchable)
    t.rights(:index_as => :stored_searchable)
    t.bibliographic_citation(:path => "bibliographicCitation", :index_as => :stored_searchable)
    t.publisher(:index_as => :stored_searchable)
    t.type2(:path => "type", :index_as => :stored_searchable)
    t.format2(:path => "format", :index_as => :stored_searchable)
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
      xml.dc(:version => "0.1", :xmlns => "http://www.fedora.info/definitions/",
             "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
             "xmlns:dcadesc" => "http://nils.lib.tufts.edu/dcadesc/",
             "xmlns:dcatech" => "http://nils.lib.tufts.edu/dcatech/",
             "xmlns:xlink" => "http://www.w3.org/1999/xlink") {
        xml['dc'].title
        xml['dc'].creator
        xml['dc'].source
        xml['dc'].description
        xml['dc'].send(:"date.created")
        xml['dc'].send(:"date.available")
        xml['dc'].send(:"date.issued")
        xml['dc'].identifier
        xml['dc'].rights
        xml['dc'].bibliographicCitation
        xml['dc'].publisher
        xml['dc'].type
        xml['dc'].format
        xml['dc'].extent
        xml['dcadesc'].persname
        xml['dcadesc'].corpname
        xml['dcadesc'].geogname
        xml['dcadesc'].subject
        xml['dcadesc'].funder
        xml['dcadesc'].temporal
        xml['dcatech'].resolution
        xml['dcadesc'].bitdepth
        xml['dcadesc'].colorspace
        xml['dcadesc'].filesize
      }
    end

    #Feels hacky but I can't come up with another way to ensure the namespace
    #gets set correctly here.
    #builder.doc.root.name="dca_dc:dc"
    #The funny thing is that while the above makes the xml *look* like our XML
    #Fedora itself complains that the dca_dc is not bound and the XML is not well
    #formed makes me wonder if we've been generally wrong on this all along.

    return builder.doc
  end
end
