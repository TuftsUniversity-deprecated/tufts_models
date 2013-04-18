class DcaAdmin < ActiveFedora::OmDatastream
  set_terminology do |t|
    t.root(:path => "admin", 'xmlns:dca_admin' => "http://nils.lib.tufts.edu/dca_admin/", 'xmlns:dc'=>"http://purl.org/dc/elements/1.1/", 'xmlns:dcterms'=>"http://purl.org/dc/terms/", 'xmlns:admin'=> "http://nils.lib.tufts.edu/admin/", 'xmlns'=>"http://www.fedora.info/definitions/", 'xmlns:xlink'=>"http://www.w3.org/1999/xlink")
    t.published_at(:path => "publishedAt", :type=>:time)
    t.edited_at(:path => "editedAt", :type=>:time)
  end

  def self.xml_template
    Nokogiri::XML('<dca_admin:admin xmlns:dca_admin="http://nils.lib.tufts.edu/dca_admin/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:admin="http://nils.lib.tufts.edu/admin/" xmlns="http://www.fedora.info/definitions/" xmlns:xlink="http://www.w3.org/1999/xlink"/>')
    
  end
end
