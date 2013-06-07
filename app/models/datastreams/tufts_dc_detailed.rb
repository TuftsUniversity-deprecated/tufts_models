class TuftsDcDetailed < ActiveFedora::OmDatastream

  # 2012-01-23 decided to make everything searchable here and handle facetable in the to_solr methods of the
  # models

  set_terminology do |t|
    t.root(path: "dc", "xmlns" => "http://purl.org/dc/elements/1.1/",
           "xmlns:dca_dc" => "http://nils.lib.tufts.edu/dca_dc/",
           "xmlns:dcadec" => "http://nils.lib.tufts.edu/dcadesc/",
           "xmlns:dcatech" => "http://nils.lib.tufts.edu/dcatech/",
           "xmlns:dcterms" => "http://purl.org/d/terms/",
           "xmlns:xlink" => "http://www.w3.org/1999/xlink")
    t.identifier
    t.alternative(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Alternative Title")
    t.creator(:index_as => :stored_searchable, :label => "Creator")
    t.contributor(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Contributor")
    t.description(:index_as => :stored_searchable, :label => "Description")
    t.abstract(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Abstract")
    t.toc(:namespace_prefix => "dcterms", :path => "tableOfContents", :index_as => :stored_searchable, :label => "Table of Contents")
    t.publisher( :index_as => :stored_searchable, :label => "Publisher")
    t.source(:index_as => :stored_searchable, :label => "Source")
    t.date(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Date")
    t.date_created(:namespace_prefix => 'dcterms', :path => "created", :index_as => :displayable, :label => "Date Created")
    t.date_copyrighted(:namespace_prefix => "dcterms", :path => "dateCopyrighted", :index_as => :stored_searchable, :label => "Date Copyrighted")
    t.date_submitted(:namespace_prefix => "dcterms", :path => "dateSubmitted", :index_as => :stored_searchable, :label => "Date Submitted")
    t.date_accepted(:namespace_prefix => "dcterms", :path => "dateAccepted", :index_as => :stored_searchable, :label => "Date Accepted")
    t.date_issued(:namespace_prefix => 'dcterms', :path => "issued", :index_as => :stored_searchable, :label => "Date Issued")
    t.date_available(:namespace_prefix => 'dcterms', :path => "available", :index_as => :stored_searchable, :label => "Date Available")
    t.date_modified(:namespace_prefix => "dcterms", :path => "modified", :index_as => :stored_searchable, :label => "Date Modified")
    t.language(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Language")

    t.type(:index_as => :stored_searchable, :label => "Type")
    t.format(:index_as => :stored_searchable, :label => "Format")
    t.extent(:index_as => :stored_searchable, :label => "Extent")
    t.medium(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Medium")

    t.persname(:namespace_prefix => "dcadesc", :path => "persname", :index_as => :stored_searchable, :label => "Person Name")
    t.corpname(:namespace_prefix => "dcadesc", :path => "corpname", :index_as => :stored_searchable, :label => "Corporate Name")
    t.geogname(:namespace_prefix => "dcadesc", :path => "geogname", :index_as => :stored_searchable, :label => "Geographic Name")

    t.subject(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Subject")
    t.genre(:namespace_prefix => "dcadesc", :index_as => :stored_searchable, :label => "DCA Genre")

    t.provenance(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Provenance")
    t.rights(:index_as => :stored_searchable, :label => "Rights")

    t.access_rights(:namespace_prefix => "dcterms", :path => "accessRights", :index_as => :stored_searchable, :label => "Access Rights")
    t.rights_holder(:namespace_prefix => "dcterms", :path => "rightsHolder", :index_as => :stored_searchable, :label => "Rights Holder")
    t.license(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "License")
    t.replaces(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Replaces")
    t.isReplacedBy(:namespace_prefix => "dcterms", :path => "isReplacedBy", :index_as => :stored_searchable, :label => "Is Replaced By")
    t.hasFormat(:namespace_prefix => "dcterms", :path => "hasFormat", :index_as => :stored_searchable, :label => "Has Format")
    t.isFormatOf(:namespace_prefix => "dcterms", :path => "isFormatOf", :index_as => :stored_searchable, :label => "Is Format Of")
    t.hasPart(:namespace_prefix => "dcterms", :path => "hasPart", :index_as => :stored_searchable, :label => "Has Part")
    t.isPartOf(:namespace_prefix => "dcterms", :path => "isPartOf", :index_as => :stored_searchable, :label => "Is Part Of")
    t.accruralPolicy(:namespace_prefix => "dcterms", :path => "accrualPolicy", :index_as => :stored_searchable, :label => "Accrual Policy")
    t.audience(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Audience")
    t.references(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "References")
    t.spatial(:namespace_prefix => "dcterms", :path => "spatial", :index_as => :stored_searchable, :label => "Spatial Coverage")


    t.bibliographic_citation(:namespace_prefix => "dcterms", :path => "bibliographicCitation", :index_as => :stored_searchable, :label => "Bibliographic Citation")
    t.temporal(:namespace_prefix => "dcterms", :index_as => :stored_searchable, :label => "Temporal")
    t.funder(:namespace_prefix => "dcadesc", :index_as => :stored_searchable, :label => "Funder")
    t.resolution(:namespace_prefix => "dcatech", :index_as => :stored_searchable, :label => "Resolution")
    t.bitdepth(:namespace_prefix => "dcatech", :path => "bitdepth", :index_as => :stored_searchable, :label => "Bit Depth")
    t.colorspace(:namespace_prefix => "dcatech", :path => "colorspace", :index_as => :stored_searchable, :label => "Color Space")
    t.filesize(:namespace_prefix => "dcatech", :path => "fileSize", :index_as => :stored_searchable, :label => "File Size")



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
             "xmlns:dcterms" => "http://purl.org/d/terms/",
             "xmlns:xlink" => "http://www.w3.org/1999/xlink") 
    end
    builder.doc
  end
end
