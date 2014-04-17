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
end
