  class TuftsFileMeta  < ActiveFedora::OmDatastream

    set_terminology do |t|
      t.root(:path=>"file", :xmlns=>"http://demo.lib.tufts.edu/dca_file/", :schema=>"") {
      t.fileName
      t.extent
      }
    end

    # Generates an empty Mods Article (used when you call ModsArticle.new without passing in existing xml)
    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.file(:version=>"0.1", "xmlns:dca_file"=>"http://demo.lib.tufts.edu/dca_file/") {
          xml.fileName
          xml.extent
          }
      end
      return builder.doc
    end

  end

