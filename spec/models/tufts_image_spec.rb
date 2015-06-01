require 'spec_helper'

describe TuftsImage do

  it 'has methods to support a draft version of the object' do
    expect(described_class).to respond_to(:build_draft_version)
  end

  describe "to_class_uri" do
    subject { described_class.to_class_uri }
    it { is_expected.to eq 'info:fedora/cm:Image.4DS' }
  end

  describe "external_datastreams" do
    let(:image) { described_class.new }
    subject { image.external_datastreams.keys }
    it { is_expected.to include('Advanced.jpg', 'Basic.jpg', 'Archival.tif', 'Thumbnail.png') }
  end

  describe "#original_file_datastreams" do
    subject { described_class.original_file_datastreams }
    it { is_expected.to eq ["Archival.tif"] }
  end

  describe "#default_datastream" do
    subject { described_class.default_datastream }
    it { is_expected.to eq 'Archival.tif' }
  end

  describe "create_derivatives" do
    before do
      subject.inner_object.pid = 'tufts:MISS.ISS.IPPI'
    end
    describe "basic" do
      before { subject.create_basic }

      it "should create Basic.jpg" do
        expect(File.exists?(subject.local_path_for('Basic.jpg', 'jpg'))).to be_truthy
        expect(subject.datastreams["Basic.jpg"].dsLocation).to eq "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/basic_jpg/MISS.ISS.IPPI.basic.jpg"
        expect(subject.datastreams["Basic.jpg"].mimeType).to eq "image/jpeg"
      end
    end

    describe "advanced" do
      before { subject.create_advanced }
      it "should create Advanced.jpg" do
        expect(File.exists?(subject.local_path_for('Advanced.jpg', 'jpg'))).to be_truthy
        expect(subject.datastreams["Advanced.jpg"].dsLocation).to eq "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/advanced_jpg/MISS.ISS.IPPI.advanced.jpg"
        expect(subject.datastreams["Advanced.jpg"].mimeType).to eq "image/jpeg"
      end
    end

    describe "thumbnail" do
      before { subject.create_thumbnail }
      it "should create Thumbnail.png" do
        expect(File.exists?(subject.local_path_for('Thumbnail.png', 'png'))).to be_truthy
        expect(subject.datastreams["Thumbnail.png"].dsLocation).to eq "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/thumb_png/MISS.ISS.IPPI.thumbnail.png"
        expect(subject.datastreams["Thumbnail.png"].mimeType).to eq "image/png"
      end
    end

  end


  describe "to_solr" do
    subject { image.to_solr }

    context "for a regular object" do
      let(:image) { described_class.new(pid: 'tufts:1', title: 'Foo') }

      it "should create a solr document with pid, title, etc" do
        expect(subject[:id]).to eq 'tufts:1'
        expect(subject['title_tesim']).to eq ['Foo']
      end

      context "with BCE date created" do
        it "creates a solr document with appropriately formatted date" do
          image.date_created = ['-0462']
          expect(subject['date_created_formatted_tesim']).to eq ['462 BCE']
        end
      end

      context "with CE date created" do
        it "creates a solr document with appropriately formatted date" do
          image.date_created = ['1963']
          expect(subject['date_created_formatted_tesim']).to eq ['1963']
        end
      end
    end
  end
end
