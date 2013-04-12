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

end
