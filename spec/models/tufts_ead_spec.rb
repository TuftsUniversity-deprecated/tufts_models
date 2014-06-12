require 'spec_helper'

describe TuftsEAD do
  
  describe "with access rights" do
    before do
      @ead = TuftsEAD.new(title: 'test ead', displays: ['dl'])
      @ead.read_groups = ['public']
      @ead.save!
    end

    after do
      @ead.destroy
    end

    let (:ability) {  Ability.new(nil) }

    it "should be visible to a not-signed-in user" do
      ability.can?(:read, @ead.pid).should be_truthy
    end
  end

  it "should have an original_file_datastreams" do
    TuftsEAD.original_file_datastreams.should == ['Archival.xml']
  end

  describe "to_class_uri" do
    subject {TuftsEAD}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Text.EAD'
    end
  end

end
