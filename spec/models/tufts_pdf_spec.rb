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
    expect(TuftsPdf.original_file_datastreams).to eq %w(Archival.pdf Transfer.binary)
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

  describe "#valid_type_for_datastream?" do
    subject { TuftsPdf.new }

    context "for the Archival.pdf datastream" do
      it "allows various expected PDF mime types" do
        %w(application/pdf application/x-pdf application/acrobat applications/vnd.pdf text/pdf text/x-pdf).each do |type|
          expect(subject.valid_type_for_datastream?(TuftsPdf::PDF_CONTENT_DS, type)).to be_truthy
        end
      end

      it "does not allow some other mime type" do
        expect(subject.valid_type_for_datastream?(TuftsPdf::PDF_CONTENT_DS, "image/jpeg")).to be_falsey
      end

      it "does not allow a blank string" do
        expect(subject.valid_type_for_datastream?(TuftsPdf::PDF_CONTENT_DS, "   ")).to be_falsey
      end

      it "does not allow an empty string" do
        expect(subject.valid_type_for_datastream?(TuftsPdf::PDF_CONTENT_DS, "")).to be_falsey
      end

    end

  end
end
