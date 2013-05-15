require 'spec_helper'

describe TuftsGenericObject do
  
  describe "with access rights" do
    before do
      @generic_object = TuftsGenericObject.new(title: 'test generic')
      @generic_object.read_groups = ['public']
      @generic_object.save!
    end

    after do
      @generic_object.destroy
    end

    let (:ability) {  Ability.new(nil) }

    it "should be visible to a not-signed-in user" do
      ability.can?(:read, @generic_object.pid).should be_true
    end
  end

  describe "to_class_uri" do
    subject {TuftsGenericObject}
    its(:to_class_uri) {should == 'info:fedora/cm:Object.Generic'}
  end

  # it "should have an original_file_datastream" do
  #   TuftsGenericObject.original_file_datastream.should == "GENERIC-CONTENT"
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
      subject.remote_url_for('GENERIC-CONTENT', 'zip').should == 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MS054/generic/MS054.003.DO.02108.zip'
    end
    it "should give a local_path" do
      subject.local_path_for('GENERIC-CONTENT', 'zip').should == "#{Rails.root}/spec/fixtures/local_object_store/data01/tufts/central/dca/MS054/generic/MS054.003.DO.02108.zip"
    end
  end
end
