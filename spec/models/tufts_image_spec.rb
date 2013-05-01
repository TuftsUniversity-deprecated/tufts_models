require 'spec_helper'

describe TuftsImage do
  
  describe "with access rights" do
    before do
      @image = TuftsImage.new
      @image.read_groups = ['public']
      @image.save!
    end

    after do
      @image.destroy
    end

    let (:ability) {  Ability.new(nil) }

    it "should be visible to a not-signed-in user" do
      ability.can?(:read, @image.pid).should be_true
    end
  end

  describe "to_class_uri" do
    subject {TuftsImage}
    its(:to_class_uri) {should == 'info:fedora/cm:Image.4DS'}
  end

  describe "external_datastreams" do
    it "should have the correct ones" do
      subject.external_datastreams.keys.should include('Advanced.jpg', 'Basic.jpg', 'Archival.tif', 'Thumbnail.png')
    end
  end

  it "should have an original_file_datastream" do
    TuftsImage.original_file_datastream.should == "Archival.tif"
  end

  describe "an image with a pid" do
    before do
      subject.inner_object.pid = 'tufts:MS054.003.DO.02108'
    end
    it "should give a remote url" do
      subject.remote_url_for('Archival.tif').should == 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MS054/archival_tif/MS054.003.DO.02108.archival.tif'
    end
    it "should give a local_path" do
      subject.local_path_for('Archival.tif').should == '/tdr/dcadata02/tufts/central/dca/fake_bucket/data01/tufts/central/dca/MS054/archival_tif/MS054.003.DO.02108.archival.tif'
    end
  end



end
