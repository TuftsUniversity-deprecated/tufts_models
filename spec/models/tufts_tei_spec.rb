require 'spec_helper'

describe TuftsTEI do

  it 'has methods to support a draft version of the object' do
    expect(described_class).to respond_to(:build_draft_version)
  end

  describe "#default_datastream" do
    subject { described_class.default_datastream }
    it { is_expected.to eq 'Archival.xml' }
  end

  describe "to_class_uri" do
    subject { described_class.to_class_uri }
    it { is_expected.to eq 'info:fedora/cm:Text.TEI' }
  end

  describe '#to_solr' do
    subject { TuftsTEI.new(pid: 'tufts:ms102.001', title: 'some title') }

    before do
      subject.add_relationship(:has_model, 'info:fedora/cm:Text.TEI')
    end

    it 'sets object type as Text' do
      solr_doc = subject.to_solr
      expect(solr_doc['object_type_sim']).to eq ['Text']
    end
  end
end
