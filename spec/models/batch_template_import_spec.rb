require 'spec_helper'

describe BatchTemplateImport do
  subject { FactoryGirl.build(:batch_template_import) }

  it 'has a display name' do
    expect(subject.display_name).to eq 'Template Import'
  end

  it 'requires a template_id' do
    subject.template_id = nil
    expect(subject.valid?).to be_falsey
    expect(subject.errors[:template_id]).to eq ["can't be blank"]
  end

  it 'has a getter method for its template' do
    template = TuftsTemplate.find(subject.template_id)
    expect(subject.template).to eq template
  end

  it 'requires a record type' do
    subject.record_type = nil
    expect(subject.valid?).to be_falsey
    expect(subject.errors[:record_type]).to eq ["can't be blank"]
  end

  it 'white lists the record types' do
    expect(BatchTemplateImport.valid_record_types).to_not be_empty
  end

  it 'is invalid if record type is invalid' do
    subject.record_type = 'TuftsTemplate'
    expect(subject.valid?).to be_falsey
    expect(subject.errors[:base]).to eq ["The template does not have the required attributes for the selected record type."]
  end

  it 'based on record type, it validates required fields' do
    subject.record_type = 'TuftsPdf'
    template = TuftsTemplate.find(subject.template_id)
    template.update_attributes(title: nil)  # title is required on TuftsPdf
    expect(subject.valid?).to be_falsey
    expect(subject.errors[:base]).to eq ["The template does not have the required attributes for the selected record type."]
  end

end
