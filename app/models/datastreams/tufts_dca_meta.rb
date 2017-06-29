class TuftsDcaMeta < ActiveFedora::OmDatastream

  # 2012-01-23 decided to make everything searchable here and handle facetable in the to_solr methods of the
  # models

  DC_ELEMENTS = 'http://purl.org/dc/elements/1.1/'

  set_terminology do |t|
    t.root("path" => "dc",
           # use explicit namespaces for all terms to ensure backwards compatibility with other Tufts (non-hydra) applications
           "xmlns:dc" => DC_ELEMENTS,
           "xmlns:dca_dc" => "http://nils.lib.tufts.edu/dca_dc/",
           "xmlns:dcadesc" => "http://nils.lib.tufts.edu/dcadesc/",
           "xmlns:dcatech" => "http://nils.lib.tufts.edu/dcatech/",
           "xmlns:dcterms" => "http://purl.org/dc/terms/",
           "xmlns:xlink" => "http://www.w3.org/1999/xlink")
    t.title(:namespace_prefix => "dc", :index_as => [:stored_searchable, :sortable])
    t.creator(:namespace_prefix => "dc", :index_as => [:stored_searchable, :sortable])
    t.source(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.description(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.date_created(:path => "date.created", :namespace_prefix => "dc", :index_as => :stored_searchable)
    t.date_available(:path => "date.available", :namespace_prefix => "dc", :index_as => :stored_searchable)
    t.date_issued(:path => "date.issued", :namespace_prefix => "dc", :index_as => :stored_searchable)
    t.identifier(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.rights(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.bibliographic_citation(:path => "bibliographicCitation", :namespace_prefix => "dc", :index_as => :stored_searchable)
    t.publisher(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.type(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.format(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.extent(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.persname(:namespace_prefix => "dcadesc", :index_as => :stored_searchable)
    t.corpname(:namespace_prefix => "dcadesc", :index_as => :stored_searchable)
    t.geogname(:namespace_prefix => "dcadesc", :index_as => :stored_searchable)
    t.genre(:namespace_prefix => "dcadesc",  :index_as => :stored_searchable)
    t.subject(:namespace_prefix => "dcadesc", :index_as => :stored_searchable)
    t.funder(:namespace_prefix => "dcadesc", :index_as => :stored_searchable)
    t.temporal(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.resolution(:namespace_prefix => "dcatech", :index_as => :stored_searchable)
    t.bitdepth(:namespace_prefix => "dcatech", :index_as => :stored_searchable)
    t.colorspace(:namespace_prefix => "dcatech", :index_as => :stored_searchable)
    t.filesize(:namespace_prefix => "dcatech", :index_as => :stored_searchable)
    t.date(namespace_prefix: "dcterms", index_as: :stored_searchable, label: "Date")
    t.isPartOf(namespace_prefix: "dcterms", path: "isPartOf", index_as: :stored_searchable, label: "Is Part Of")
  end

  # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
  # I thought my confusion here was in what OM was doing but its actually a lack of knowledge
  # in how Nokogiri works.
  # see here for more details:
  # http://nokogiri.org/Nokogiri/XML/Builder.html
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.dc(:version => "0.1",
             "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
             "xmlns:dcadesc" => "http://nils.lib.tufts.edu/dcadesc/",
             "xmlns:dcatech" => "http://nils.lib.tufts.edu/dcatech/",
             "xmlns:dcterms" => "http://purl.org/dc/terms/",
             "xmlns:xlink" => "http://www.w3.org/1999/xlink")
    end

    builder.doc
  end

  def prefix
    ""
  end

  def term_values_append(opts={})
    ensure_dc_namespace_exists!
    ensure_dcterms_namespace_exists!
    super
  end

  # primary_solr_name() is implemented so that collections can be loaded from solr rather than
  # from Fedora, to improve performance.  primary_solr_name() only returns values for solr
  # fields that are used;  if others are used in the future they will have to be added too.
  def primary_solr_name(field)
    if field == :title then
      "title_tesim"
    elsif field == :description then
      "description_tesim"
    elsif field == :genre then
      "genre_tesim"
    else
      ""
    end
  end

  # type() is implemented so that collections can be loaded from solr rather than
  # from Fedora, to improve performance.  If any fields are in date format it should
  # return :date;  otherwise it doesn't matter what it returns, but it needs to be
  # defined.
  def self.type(field)
    return nil
  end

  private

    # TDL staff decided to change from having a default namespace to a prefixed namespace.
    # This method ensures the prefixed namespace is added to the document
    def ensure_dc_namespace_exists!
      unless ng_xml.namespaces.key? 'xmlns:dc'
        ng_xml.root.add_namespace_definition('dc', DC_ELEMENTS)
      end
    end

    def ensure_dcterms_namespace_exists!
      unless ng_xml.namespaces.key? 'xmlns:dcterms'
        ng_xml.root.add_namespace_definition('dcterms', 'http://purl.org/dc/terms/')
      end
    end
end
