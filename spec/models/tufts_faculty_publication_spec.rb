require 'spec_helper'

describe TuftsFacultyPublication do
  
  describe "with access rights" do
    before do
      @audio = TuftsFacultyPublication.new(title: 'test facpub', displays: ['dl'])
      @audio.read_groups = ['public']
      @audio.save!
    end

    after do
      @audio.destroy
    end

    let (:ability) {  Ability.new(nil) }

    it "should be visible to a not-signed-in user" do
      ability.can?(:read, @audio.pid).should be_true
    end
  end

  describe "to_class_uri" do
    subject {TuftsFacultyPublication}
    its(:to_class_uri) {should == 'info:fedora/cm:Text.FacPub'}
  end

  it "should have an original_file_datastream" do
    TuftsFacultyPublication.original_file_datastreams.should == ["Archival.pdf"]
  end

end
