require 'spec_helper'

describe TuftsAudio do

  describe "to_solr" do
    describe "when not saved" do
      before do
        allow(subject).to receive(:pid).and_return('changeme:999')
      end
      describe "subject field" do
        it "should save both" do
          subject.subject = ["subject1"]
          subject.funder = ["subject2"]
          solr_doc = subject.to_solr
          expect(solr_doc["subject_tesim"]).to eq ["subject1"]
          expect(solr_doc["funder_tesim"]).to eq ["subject2"]
          # TODO is this right? Presumably this is for the facet
          expect(solr_doc["subject_sim"]).to eq ["Subject1"]
        end
      end

      describe "displays" do
        it "should save it" do
          subject.displays = ["dl"]
          solr_doc = subject.to_solr
          expect(solr_doc['displays_ssim']).to eq ['dl']
        end
      end
      describe "title" do
        it "should be searchable and facetable" do
          subject.title = "My title"
          solr_doc = subject.to_solr
          expect(solr_doc['title_si']).to eq 'My title'
          expect(solr_doc['title_tesim']).to eq ['My title']
        end
      end

      describe "contributor added" do
        it "should save it" do
          subject.contributor = ["Michael Jackson"]
          solr_doc = subject.to_solr
          expect(solr_doc['names_sim']).to eq ['Michael Jackson']
        end
      end
    end

    describe "date added" do
      before do
        subject.save(validate: false)
      end
      let(:solr_doc) { subject.to_solr }

      it "should be sortable" do
        expect(solr_doc['system_create_dtsi']).to_not be_nil
      end
    end
  end

  describe "displays" do
    it "should only allow one of the approved values" do
      subject.title = 'test title' #make it valid
      subject.displays = ['dl']
      expect(subject).to be_valid
      subject.displays = ['tisch']
      expect(subject).to be_valid
      subject.displays = ['aah']
      expect(subject).to be_valid
      subject.displays = ['perseus']
      expect(subject).to be_valid
      subject.displays = ['elections']
      expect(subject).to be_valid
      subject.displays = ['dark']
      expect(subject).to be_valid
      subject.displays = ['fake']
      expect(subject).to_not be_valid
    end
  end


  describe "terms_for_editing" do
    it "has the correct values" do
      expect(subject.terms_for_editing).to eq [:identifier, :title, :alternative, :creator, :contributor, :description, :abstract, :toc, :publisher, :source, :date, :date_created, :date_copyrighted, :date_submitted, :date_accepted, :date_issued, :date_available, :date_modified, :language, :type, :format, :extent, :medium, :persname, :corpname, :geogname, :subject, :genre, :provenance, :rights, :access_rights, :rights_holder, :license, :replaces, :isReplacedBy, :hasFormat, :isFormatOf, :hasPart, :isPartOf, :accrualPolicy, :audience, :references, :spatial, :bibliographic_citation, :temporal, :funder, :resolution, :bitdepth, :colorspace, :filesize, :steward, :name, :comment, :retentionPeriod, :displays, :embargo, :status, :startDate, :expDate, :qrStatus, :rejectionReason, :note, :createdby, :creatordept]
    end
  end

  describe "required terms" do
    it "should be required" do
       expect(subject.required?(:title)).to be_truthy
       expect(subject.required?(:source2)).to be_falsey
    end
  end

  describe "to_class_uri" do
    subject {TuftsAudio}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Audio'
    end
  end

  describe "external_datastreams" do
    it "should have the correct ones" do
      expect(subject.external_datastreams.keys).to include('ACCESS_MP3', 'ARCHIVAL_SOUND')
    end
  end


  describe "push_to_production!" do
    before do
      @audio = TuftsAudio.new(title: 'foo', displays: ['dl'])
      @audio.read_groups = ['public']
      @audio.save!
    end

    after do
      @audio.destroy
    end

    it "should publish to production" do
      expect(@audio).to_not be_published
      @audio.push_to_production!
      expect(@audio).to be_published
    end
  end


  it "should have an original_file_datastream" do
    expect(TuftsAudio.original_file_datastreams).to eq ["ARCHIVAL_SOUND"]
  end

  describe "an audio with a pid" do
    before do
      subject.inner_object.pid = 'tufts:MS054.003.DO.02108'
    end
    it "should give a remote url" do
      expect(subject.remote_url_for('ARCHIVAL_SOUND', 'mp3')).to eq 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MS054/archival_sound/MS054.003.DO.02108.archival.mp3'
    end
    it "should give a local_path" do
      expect(subject.local_path_for('ARCHIVAL_SOUND', 'mp3')).to eq File.expand_path("../../fixtures/local_object_store/data01/tufts/central/dca/MS054/archival_sound/MS054.003.DO.02108.archival.mp3", __FILE__)
    end
  end
  # if mira touches an object with data stored in a legacy location it shouldn't
  # start moving that data around to the new store or looking for it somewhere
  # it is not
  describe "an audio with existing legacy datastreams on different data shares" do
    before do
      subject.inner_object.pid = 'tufts:MS054.003.DO.02108'
      subject.inner_object.datastreams['ARCHIVAL_SOUND'].dsLocation = 'http://bucket01.lib.tufts.edu/data05/tufts/central/dca/MS054/archival_sound/MS054.003.DO.02108.archival.mp3'
    end
    it "should give a remote url" do
      expect(subject.remote_url_for('ARCHIVAL_SOUND', 'mp3')).to eq 'http://bucket01.lib.tufts.edu/data05/tufts/central/dca/MS054/archival_sound/MS054.003.DO.02108.archival.mp3'
    end
    it "should give a local_path" do
      expect(subject.local_path_for('ARCHIVAL_SOUND', 'mp3')).to eq File.expand_path("../../fixtures/local_object_store/data05/tufts/central/dca/MS054/archival_sound/MS054.003.DO.02108.archival.mp3", __FILE__)
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
        expect(File).to exist(subject.local_path_for('ACCESS_MP3', 'mp3'))
        expect(subject.datastreams["ACCESS_MP3"].dsLocation).to eq "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/access_mp3/MISS.ISS.IPPI.access.mp3"
        expect(subject.datastreams["ACCESS_MP3"].mimeType).to eq "audio/mpeg"
      end
    end
  end

  # Per Mark, the audit history can be found by using fedora versioning to see the audit entries on previous versions of the object.
  describe "auditing" do
    let (:user) { FactoryGirl.create(:user) }

    describe "when metadata is updated" do
      before do
        subject.audit(user, 'updated stuff')
      end
      it "should get an entry" do
        expect(subject.audit_log.who).to eq [user.display_name]
      end
    end

    describe "when content is updated" do
      before do
        allow(subject).to receive(:content_will_update).and_return('123')
        allow(subject).to receive(:working_user).and_return(user)
        subject.title = 'title'
        subject.displays = ['dl']
        subject.save!
      end

      it "should get an entry" do
        expect(subject.audit_log.who).to eq [user.display_name]
        expect(subject.audit_log.what.first).to match /Content updated: 123/i
      end
    end
  end
end
