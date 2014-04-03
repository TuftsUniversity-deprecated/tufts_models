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

end
