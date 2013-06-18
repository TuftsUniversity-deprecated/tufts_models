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
    its(:terms_for_editing) { should == [:identifier, :title, :alternative, :creator, :contributor, :description, :abstract, :toc, :publisher, :source, :date, :date_created, :date_copyrighted, :date_submitted, :date_accepted, :date_issued, :date_available, :date_modified, :language, :type, :format, :extent, :medium, :persname, :corpname, :geogname, :subject, :genre, :provenance, :rights, :access_rights, :rights_holder, :license, :replaces, :isReplacedBy, :hasFormat, :isFormatOf, :hasPart, :isPartOf, :accrualPolicy, :audience, :references, :spatial, :bibliographic_citation, :temporal, :funder, :resolution, :bitdepth, :colorspace, :filesize, :steward, :name, :comment, :retentionPeriod, :displays, :embargo, :status, :startDate, :expDate, :qrStatus, :rejectionReason, :note]}
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
        # TODO is this right? Presumably this is for the facet
        solr_doc["subject_sim"].should == ["Subject1"]
      end
    end

    describe "displays" do
      it "should save it" do
        subject.displays = "dl"
        solr_doc = subject.to_solr
        solr_doc['displays_ssi'].should == 'dl'
      end
    end
    describe "title" do
      it "should be searchable and facetable" do
        subject.title = "My title"
        solr_doc = subject.to_solr
        solr_doc['title_si'].should == 'My title'
        solr_doc['title_tesim'].should == ['My title']
      end
    end

    describe "date added" do
      before do
        subject.save(validate: false)
        @solr_doc = subject.to_solr
      end
      it "should be sortable" do
        @solr_doc['system_create_dtsi'].should_not be_nil
      end
    end

    describe "contributor added" do
      it "should  save it" do
        subject.contributor = "Michael Jackson"
        solr_doc = subject.to_solr
        solr_doc['names_sim'].should == ['Michael Jackson']
      end
    end
  end

  describe "displays" do
    it "should only allow one of the approved values" do
      subject.title = 'test title' #make it valid
      subject.should be_valid # no value
      subject.displays = 'fake'
      subject.should_not be_valid
      subject.displays = 'dl'
      subject.should be_valid
      subject.displays = 'tisch'
      subject.should be_valid
      subject.displays = 'aah'
      subject.should be_valid
      subject.displays = 'perseus'
      subject.should be_valid
      subject.displays = 'elections'
      subject.should be_valid
      subject.displays = 'dark'
      subject.should be_valid
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


  describe "push_to_production!" do
    before do
      @audio = TuftsAudio.new(title: 'foo')
      @audio.read_groups = ['public']
      @audio.save!
    end

    after do
      @audio.destroy
    end

    it "should publish to production" do
      @audio.should_not be_published
      @audio.push_to_production!
      @audio.should be_published
    end
  end


  it "should have an original_file_datastream" do
    TuftsAudio.original_file_datastreams.should == ["ARCHIVAL_SOUND"]
  end

  describe "an audio with a pid" do
    before do
      subject.inner_object.pid = 'tufts:MS054.003.DO.02108'
    end
    it "should give a remote url" do
      subject.remote_url_for('ARCHIVAL_SOUND', 'mp3').should == 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MS054/archival_sound/MS054.003.DO.02108.archival.mp3'
    end
    it "should give a local_path" do
      subject.local_path_for('ARCHIVAL_SOUND', 'mp3').should == "#{Rails.root}/spec/fixtures/local_object_store/data01/tufts/central/dca/MS054/archival_sound/MS054.003.DO.02108.archival.mp3"
    end
  end


  # This tests depends on ffmpeg, so exlude it for travis
  describe "create_derivatives", :unless=> ENV["TRAVIS"] do
    before do
      subject.inner_object.pid = 'tufts:MISS.ISS.IPPI'
      subject.datastreams["ARCHIVAL_SOUND"].dsLocation = "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_sound/MISS.ISS.IPPI.archival.wav"
    end
    describe "basic" do
      before { subject.create_derivatives }
      it "should create ACCESS_MP3" do
        File.exists?(subject.local_path_for('ACCESS_MP3', 'mp3')).should be_true
        subject.datastreams["ACCESS_MP3"].dsLocation.should == "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/access_mp3/MISS.ISS.IPPI.access.mp3"
        subject.datastreams["ACCESS_MP3"].mimeType.should == "audio/mpeg"
      end
    end
  end

  describe "auditing" do
    describe "when metadata is updated" do
      let (:user) { FactoryGirl.create(:user) }
      before do
        subject.audit(user, 'updated stuff')
      end
      it "should get an entry" do
        subject.audit_log.who.should == [user.user_key]
      end
    end
    describe "when content is updated" do
      it "should get an entry"
    end
    describe "when the object is deleted" do
      it "should get an entry"
    end
  end
end
