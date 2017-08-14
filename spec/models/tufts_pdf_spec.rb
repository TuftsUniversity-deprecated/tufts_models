require 'spec_helper'

describe TuftsPdf do

  it 'has methods to support a draft version of the object' do
    expect(described_class).to respond_to(:build_draft_version)
  end

  describe "to_class_uri" do
    subject { described_class.to_class_uri }
    it { is_expected.to eq 'info:fedora/cm:Text.PDF' }
  end

  describe "#default_datastream" do
    subject { described_class.default_datastream }
    it { is_expected.to eq 'Archival.pdf' }
  end
 
  describe "external_datastreams" do
    let(:pdf) { described_class.new }
    subject { pdf.external_datastreams.keys }
    it { is_expected.to include('THUMBNAIL') }
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
      context "various expected PDF mime types" do

        it "allows application/pdf" do
          expect(subject.valid_type_for_datastream?(TuftsPdf::PDF_CONTENT_DS, "application/pdf")).to be_truthy
        end

        it "allows application/x-pdf" do
          expect(subject.valid_type_for_datastream?(TuftsPdf::PDF_CONTENT_DS, "application/x-pdf")).to be_truthy
        end

        it "allows application/acrobat" do
          expect(subject.valid_type_for_datastream?(TuftsPdf::PDF_CONTENT_DS, "application/acrobat")).to be_truthy
        end

        it "allows applications/vnd.pdf" do
          expect(subject.valid_type_for_datastream?(TuftsPdf::PDF_CONTENT_DS, "applications/vnd.pdf")).to be_truthy
        end

        it "allows text/pdf" do
          expect(subject.valid_type_for_datastream?(TuftsPdf::PDF_CONTENT_DS, "text/pdf")).to be_truthy
        end

        it "allows text/x-pdf" do
          expect(subject.valid_type_for_datastream?(TuftsPdf::PDF_CONTENT_DS, "text/x-pdf")).to be_truthy
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

    context "for the Transfer.binary datastream" do
      subject { lambda { |mime_type| TuftsPdf.new.valid_type_for_datastream?(TuftsPdf::TRANSFER_BINARY_DS, mime_type) } }

      it "allows PDF files" do
        expect(subject.call("application/pdf")).to be_truthy
      end

      it "allows tiff files" do
        expect(subject.call("image/tiff")).to be_truthy
      end

      it "allows a blank string" do
        expect(subject.call("  ")).to be_truthy
      end

      it "allows an empty string" do
        expect(subject.call("")).to be_truthy
      end

      it "allows nil" do
        expect(subject.call(nil)).to be_truthy
      end
    end

    context "for an unknown datastream" do
      it "raises a KeyError" do
        expect { subject.valid_type_for_datastream?("unknown", "image/jpeg") }.to raise_error(KeyError)
      end
    end

  end
end
