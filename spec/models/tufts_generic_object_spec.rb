require 'spec_helper'

describe TuftsGenericObject do
  describe "to_class_uri" do
    subject {TuftsGenericObject}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Object.Generic'
    end
  end

  # it "should have an original_file_datastream" do
  #   expect(TuftsGenericObject.original_file_datastream).to eq "GENERIC-CONTENT"
  # end

#   <foxml:datastream ID="GENERIC-CONTENT" STATE="A" CONTROL_GROUP="X" VERSIONABLE="true">
# <foxml:datastreamVersion ID="GENERIC-CONTENT.0" LABEL="Enter a label here." CREATED="2009-10-16T15:56:59.270Z" MIMETYPE="text/xml" SIZE="411">
# <foxml:xmlContent>
# <content xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.fedora.info/definitions/">
#   					        <item id="0">
#     					         <link>http://bucket01.lib.tufts.edu/data05/tufts/central/dca/MS115/generic/MS115.003.001.00003.zip</link>
#     					         <fileName>MS115.003.001.00003</fileName>
#     					         <mimeType>application/zip</mimeType>
#   					        </item>
# 				        </content>
# </foxml:xmlContent>
# </foxml:datastreamVersion>
# </foxml:datastream>

  describe "an generic content with a pid" do
    before do
      subject.inner_object.pid = 'tufts:MS054.003.DO.02108'
    end
    it "should give a remote url" do
      expect(subject.remote_url_for('GENERIC-CONTENT', 'zip')).to eq 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MS054/generic/MS054.003.DO.02108.zip'
    end
    it "should give a local_path" do
      expect(subject.local_path_for('GENERIC-CONTENT', 'zip')).to eq File.expand_path("../../fixtures/local_object_store/data01/tufts/central/dca/MS054/generic/MS054.003.DO.02108.zip", __FILE__)
    end
  end

  describe "setting items" do
    it "should accept a hash" do
      subject.item_attributes = {"0"=>{"item_id" => '0', "link"=>"link one", "mimeType"=>"mime one", "fileName"=>"file one"}, "1"=>{"item_id" => '1', "link"=>"link two", "mimeType"=>"mime two", "fileName"=>"file two"}, "2"=>{"item_id" => '2', "link"=>"link three", "mimeType"=>"mime three", "fileName"=>"file three"}}
      expect(subject.item(1).link).to eq ["link two"]
      expect(subject.item(2).item_id).to eq ["2"]
    end
  end
end
