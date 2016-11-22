require 'spec_helper'

describe TuftsAudio do

  it 'has methods to support a draft version of the object' do
    expect(TuftsAudio.respond_to?(:build_draft_version)).to be_truthy
  end

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
      subject.displays = ['trove']
      expect(subject).to be_valid
      subject.displays = ['perseus']
      expect(subject).to be_valid
      subject.displays = ['elections']
      expect(subject).to be_valid
      subject.displays = ['fake']
      expect(subject).to_not be_valid
    end
  end


  describe "terms_for_editing" do
    it "has the correct values" do
      expect(subject.terms_for_editing).to eq [:identifier, :title, :alternative, :creator, :contributor, :description, :abstract, :toc, :publisher, :source, :date, :date_created, :date_copyrighted, :date_submitted, :date_accepted, :date_issued, :date_available, :date_modified, :language, :type, :format, :extent, :medium, :persname, :corpname, :geogname, :subject, :genre, :provenance, :rights, :access_rights, :rights_holder, :license, :replaces, :isReplacedBy, :hasFormat, :isFormatOf, :hasPart, :isPartOf, :accrualPolicy, :audience, :references, :spatial, :bibliographic_citation, :temporal, :funder, :resolution, :bitdepth, :colorspace, :filesize, :steward, :name, :comment, :retentionPeriod, :displays, :embargo, :status, :startDate, :expDate, :qrStatus, :rejectionReason, :note, :createdby, :creatordept, :visibility, :download]
    end
  end

  describe "required terms" do
    it "should be required" do
      expect(subject.required?(:title)).to be_truthy
      expect(subject.required?(:source2)).to be_falsey
    end
  end

  describe "to_class_uri" do
    subject { described_class.to_class_uri }
    it { is_expected.to eq 'info:fedora/cm:Audio' }
  end

  describe "#default_datastream" do
    subject { described_class.default_datastream }
    it { is_expected.to eq 'ARCHIVAL_WAV' }
  end

  # This tests depends on ffmpeg, so exlude it for travis
  describe "create_derivatives", :unless => ENV["TRAVIS"] do
    before do
      subject.inner_object.pid = 'tufts:MISS.ISS.IPPI'
      subject.datastreams["ARCHIVAL_WAV"].dsLocation = "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_wav/MISS.ISS.IPPI.archival.wav"
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
end
