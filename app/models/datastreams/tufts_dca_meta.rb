class TuftsDcaMeta < ActiveFedora::OmDatastream

  # 2012-01-23 decided to make everything searchable here and handle facetable in the to_solr methods of the
  # models

  set_terminology do |t|
    t.root("path" => "dc", "xmlns" => "http://www.fedora.info/definitions/",
           "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
           "xmlns:dca_dc" => "http://nils.lib.tufts.edu/dca_dc/",
           "xmlns:dcadec" => "http://nils.lib.tufts.edu/dcadesc/",
           "xmlns:dcatech" => "http://nils.lib.tufts.edu/dcatech/",
           "xmlns:dcterms" => "http://purl.org/d/terms/",
           "xmlns:xlink" => "http://www.w3.org/1999/xlink")
    t.title(:namespace_prefix => "dc", :path => "title", :index_as => [:searchable], :label => "title")
    t.creator(:namespace_prefix => "dc", :path => "creator", :index_as => [:searchable], :label => "creator")
    t.source2(:namespace_prefix => "dc", :path => "source", :index_as => [:searchable], :label => "source")
    t.description(:namespace_prefix => "dc", :path => "description", :index_as => [:searchable], :label => "description")
    t.dateCreated(:namespace_prefix => "dc", :path => "date.created", :index_as => [:searchable], :label => "date created")
    t.dateAvailable(:namespace_prefix => "dc", :path => "date.available", :index_as => [:searchable], :label => "date available")
    t.dateIssued(:namespace_prefix => "dc", :path => "date.issued", :index_as => [:searchable], :label => "date issued")
    t.identifier(:namespace_prefix => "dc", :path => "identifier", :index_as => [:searchable], :label => "identifier")
    t.rights(:namespace_prefix => "dc", :path => "rights", :index_as => [:searchable], :label => "rights")
    t.bibliographicCitation(:namespace_prefix => "dc", :path => "bibliographicCitation", :index_as => [:searchable], :label => "bibliographic citation")
    t.publisher(:namespace_prefix => "dc", :path => "publisher", :index_as => [:searchable], :label => "publisher")
    t.type2(:namespace_prefix => "dc", :path => "type", :index_as => [:searchable], :label => "type")
    t.format2(:namespace_prefix => "dc", :path => "format", :index_as => [:searchable], :label => "format")
    t.extent(:namespace_prefix => "dc", :path => "publisher", :index_as => [:searchable], :label => "extent")
    t.persname(:namespace_prefix => "dcadesc", :path => "persname", :index_as => [:searchable], :label => "person")
    t.corpname(:namespace_prefix => "dcadesc", :path => "corpname", :index_as => [:searchable], :label => "corporation")
    t.geogname(:namespace_prefix => "dcadesc", :path => "geogname", :index_as => [:searchable], :label => "geographic name")
    t.genre(:namespace_prefix => "dcadesc", :path => "genre", :index_as => [:searchable], :label => "genre")
    t.subject(:namespace_prefix => "dcadesc", :path => "subject", :index_as => [:searchable], :label => "subject")
    t.funder(:namespace_prefix => "dcadesc", :path => "funder", :index_as => [:searchable], :label => "funder")
    t.temporal(:namespace_prefix => "dc", :path => "temporal", :index_as => [:searchable], :label => "temporal")
    t.resolution(:namespace_prefix => "dcatech", :path => "resolution", :index_as => [:searchable], :label => "resolution")
    t.bitDepth(:namespace_prefix => "dcatech", :path => "bitdepth", :index_as => [:searchable], :label => "bit depth")
    t.colorSpace(:namespace_prefix => "dcatech", :path => "colorspace", :index_as => [:searchable], :label => "color space")
    t.filesize(:namespace_prefix => "dcatech", :path => "fileSize", :index_as => [:searchable], :label => "file size")
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
             "xmlns:dcterms" => "http://purl.org/d/terms/",
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
