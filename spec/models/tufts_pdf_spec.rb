require 'spec_helper'

describe TuftsPdf do

  it 'has methods to support a draft version of the object' do
    expect(TuftsPdf.respond_to?(:build_draft_version)).to be_truthy
  end

  describe "to_class_uri" do
    subject { TuftsPdf }
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Text.PDF'
    end
  end

  it "should have an original_file_datastream" do
    expect(TuftsPdf.original_file_datastreams).to eq ["Archival.pdf"]
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
