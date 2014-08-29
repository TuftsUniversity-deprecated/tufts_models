require 'spec_helper'

describe TuftsPdf do

  describe "to_class_uri" do
    subject { TuftsPdf }
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Text.PDF'
    end
  end

  it "should have an original_file_datastream" do
    expect(TuftsPdf.original_file_datastreams).to eq ["Archival.pdf"]
  end

  describe "an pdf with a pid" do
    before do
      subject.inner_object.pid = 'tufts:MS054.003.DO.02108'
    end
    describe "and a collection" do
      let(:collection_id) { 'tufts:UA069.001.DO.UA015' }
      before do
        unless ActiveFedora::Base.exists? collection_id
          ActiveFedora::FixtureLoader.new('spec/fixtures').import_and_index(collection_id)
        end
        subject.collection_id = collection_id
      end
      it "should give a remote URL" do
        #http://bucket01.lib.tufts.edu/data05/tufts/central/dca/UA015/archival_pdf/{#PID}.archival.pdf
        expect(subject.remote_url_for('Archival.pdf', 'pdf')).to eq 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/UA015/archival_pdf/MS054.003.DO.02108.archival.pdf'
      end

    end
    it "should give a remote url" do
      expect(subject.remote_url_for('Archival.pdf', 'pdf')).to eq 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MS054/archival_pdf/MS054.003.DO.02108.archival.pdf'
    end
    it "should give a local_path" do
      expect(subject.local_path_for('Archival.pdf', 'pdf')).to eq File.expand_path("../../fixtures/local_object_store/data01/tufts/central/dca/MS054/archival_pdf/MS054.003.DO.02108.archival.pdf", __FILE__)
    end
  end

  describe "attributes" do
    it "should have createdby fields" do
      expect(subject.createdby).to be_nil
      subject.createdby = 'selfdep'
      expect(subject.createdby).to eq 'selfdep'
    end
    it "should have creatordept" do

      expect(subject.creatordept).to be_nil
      subject.creatordept = 'UA005.014'
      expect(subject.creatordept).to eq 'UA005.014'
    end

  end

  describe "to_solr" do
    before do
      allow(subject).to receive(:pid).and_return('foo:123')
    end
    let(:solr_doc) {subject.to_solr}
    describe "on a self-deposit" do
      before do
        subject.createdby = 'selfdep'
      end
      it "should have deposit_method_ssi" do
        expect(solr_doc['deposit_method_ssi']).to eq 'self-deposit'
      end
    end
  end
end
