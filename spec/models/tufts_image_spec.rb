require 'spec_helper'

describe TuftsImage do

  it 'has methods to support a draft version of the object' do
    expect(TuftsImage.respond_to?(:build_draft_version)).to be_truthy
  end

  describe "to_class_uri" do
    subject {TuftsImage}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Image.4DS'
    end
  end

  describe "external_datastreams" do
    it "should have the correct ones" do
      expect(subject.external_datastreams.keys).to include('Advanced.jpg', 'Basic.jpg', 'Archival.tif', 'Thumbnail.png')
    end
  end

  it "should have an original_file_datastream" do
    expect(TuftsImage.original_file_datastreams).to eq ["Archival.tif"]
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
      let(:image) { TuftsImage.new(pid: 'tufts:1', title: 'Foo') }

      it "should create a solr document with pid, title, etc" do
        expect(subject[:id]).to eq 'tufts:1'
        expect(subject['title_tesim']).to eq ['Foo']
      end

      it "should create a solr document with appropriately formatted BCE date created" do
        image.date_created = ['-0462']
        expect(subject['date_created_formatted_tesim']).to eq ['462 BCE']
      end

      it "should create a solr document with an appropriately CE date" do
        image.date_created = ['1963']
        expect(subject['date_created_formatted_tesim']).to eq ['1963']
      end

    end

  end
end
