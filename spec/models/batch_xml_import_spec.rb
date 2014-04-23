require 'spec_helper'

describe BatchXmlImport do
  subject { FactoryGirl.build(:batch_xml_import) }

  it 'has a display name' do
    expect(subject.display_name).to eq 'Xml Import'
  end

  it 'requires a metadata file' do
    subject.remove_metadata_file!
    expect(subject).to_not be_valid
  end

  it "saves uploaded_files correctly" do
    uploaded_files = {"foo.jpg" => "tufts:1"}
    id = FactoryGirl.create(:batch_xml_import, uploaded_files: uploaded_files).id
    expect(Batch.find(id).uploaded_files).to eq uploaded_files
  end

  it 'requires the metadata file to be valid' do
    xml = "<input><digitalObject></digitalObject></input>"
    allow(subject.metadata_file).to receive(:read) { xml }
    expect(subject).to_not be_valid
    MetadataXmlParser.validate(xml).each do |error|
      expect(subject.errors.full_messages).to include error.message
    end
  end

  it 'only checks the validity of the metadata file if it has changed' do
    expect(MetadataXmlParser).to receive(:validate).once { [] }
    subject.save
    expect(MetadataXmlParser).to receive(:validate).never
    subject.save
  end

  it 'calls read on the UploadedFile' do
    xml = "<input><digitalObject></digitalObject></input>"
    # we need it to call read here because Nokogiri won't correctly parse an
    # ActionDispatch::Http::UploadedFile
    expect(subject.metadata_file).to receive(:read) { xml }.once
    subject.valid?
  end

  describe ".pids" do
    it "doesn't let you assign pids directly" do
      expect{FactoryGirl.build(:batch_xml_import).pids = []}.to raise_exception(NotImplementedError)
    end
  end

  describe ".uploaded_files" do
    it "gets pids from the uploaded_files" do
      m = FactoryGirl.build(:batch_xml_import)
      expect(m.pids).to eq []
      m.uploaded_files = {"foo.jpg" => "tufts:1"}
      expect(m.pids).to eq ["tufts:1"]
    end

    it "provides a default value for .uploade_files" do
      m = FactoryGirl.build(:batch_xml_import)
      expect(m.uploaded_files).to eq({})
      m.uploaded_files['foo.txt'] = 'tufts:1'
      expect(m.uploaded_files).to eq({'foo.txt' => 'tufts:1'})
    end
  end

  describe ".missing_files" do
    it "shows missing files" do
      uploaded_files = {"hello.pdf" => "tufts:1"}
      m = FactoryGirl.create(:batch_xml_import, uploaded_files: uploaded_files)
      expect(m.missing_files.count).to eq 4
      expect(m.missing_files).to_not include("hello.pdf")
    end
  end
end
