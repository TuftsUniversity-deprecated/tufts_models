class TuftsGenericMeta  < ActiveFedora::OmDatastream

  set_terminology do |t|
    t.root(:path=>"content", :xmlns=>"http://www.fedora.info/definitions/",
    "xmlns:xlink"=>"http://www.w3.org/1999/xlink")
    t.item  {
      t.link
      t.fileName
      t.mimeType
      }

  end

  # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
  def self.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.content(:version=>"0.1", "xmlns"=>"http://www.fedora.info/definitions/","xmlns:xlink"=>"http://www.w3.org/1999/xlink"){
          xml.item{
            xml.link
            xml.fileName
            xml.mimeType
          }
        }
    end
    return builder.doc
  end

end

# Example: 
# <content xmlns="http://www.fedora.info/definitions/" xmlns:xlink="http://www.w3.org/1999/xlink">
#   <item id="0">
#     <link>http://dl.dropbox.com/u/43702278/MS115.003.001.00001.gz</link>
#     <fileName>MS115.003.001.00001</fileName>
#     <mimeType>application/x-gzip</mimeType>
#   </item>
# </content>
