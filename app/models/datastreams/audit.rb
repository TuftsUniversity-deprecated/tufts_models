class Audit < ActiveFedora::OmDatastream
  set_terminology do |t|
    t.root(:path => "audit")
    t.who
    t.what
    t.when(type: :time)
  end

  def self.xml_template
    Nokogiri::XML('<audit />')
  end

  def prefix
    "audit_log__"
  end
end
