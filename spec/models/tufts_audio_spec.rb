require 'spec_helper'

describe TuftsAudio do
  
  describe "with access rights" do
    before do
      @audio = TuftsAudio.new(title: 'foo')
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

  describe "terms_for_editing" do
    its(:terms_for_editing) { should == [:title, :creator, :source2, :description, :dateCreated, :dateAvailable, 
                           :dateIssued, :identifier, :rights, :bibliographicCitation, :publisher,
                           :type2, :format2, :extent, :persname, :corpname, :geogname, :genre,
                           :subject, :funder, :temporal, :resolution, :bitDepth, :colorSpace, 
                           :filesize]}
  end

  describe "required terms" do
    it "should be required" do
       subject.required?(:title).should be_true
       # subject.required?(:creator).should be_true
       # subject.required?(:description).should be_true
       subject.required?(:source2).should be_false
    end
  end

  describe "to_solr" do
    describe "subject field" do
      it "should save both" do
        subject.subject = "subject1"
        subject.funder = "subject2"
        solr_doc = subject.to_solr
        solr_doc["subject_tesim"].should == ["subject1"]
        solr_doc["funder_tesim"].should == ["subject2"]
        # TODO is this right?
        solr_doc["subject_sim"].should == ["Subject1"]
      end
    end
  end

  describe "to_class_uri" do
    subject {TuftsAudio}
    its(:to_class_uri) {should == 'info:fedora/cm:Audio'}
  end

  describe "external_datastreams" do
    it "should have the correct ones" do
      subject.external_datastreams.keys.should include('ACCESS_MP3', 'ARCHIVAL_SOUND')
    end
  end

end
