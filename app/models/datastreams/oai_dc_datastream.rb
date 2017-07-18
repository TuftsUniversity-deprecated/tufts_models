class OaiDcDatastream < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root("path" => "oai_dc",
           # use explicit namespaces for all terms to ensure backwards compatibility with other Tufts (non-hydra) applications
           "xmlns:oai_dc" => "http://www.openarchives.org/OAI/2.0/oai_dc/",
           "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
           "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
           "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd")
    t.title(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.creator(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.subject(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.description(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.publisher(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.contributor(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.date(namespace_prefix: "dc", index_as: :stored_searchable)
    t.type(namespace_prefix: "dc", index_as: :stored_searchable)
    t.format(namespace_prefix: "dc", index_as: :stored_searchable)
    t.identifier(namespace_prefix: "dc", index_as: :stored_searchable)
    t.source(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.language(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.relation(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.coverage(:namespace_prefix => "dc", :index_as => :stored_searchable)
    t.rights(:namespace_prefix => "dc", :index_as => :stored_searchable)
  end
  
   # This is the prefix for all of the generated solr fields
  def prefix
    'oai_dc' 
  end

  def self.xml_template
    Nokogiri::XML('<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd"/>')
  end
end