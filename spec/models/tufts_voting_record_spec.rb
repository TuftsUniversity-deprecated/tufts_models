require 'spec_helper'

describe TuftsVotingRecord do
  it 'has methods to support a draft version of the object' do
    expect(described_class).to respond_to(:build_draft_version)
  end

  describe "#default_datastream" do
    subject { described_class.default_datastream }
    it { is_expected.to eq 'RECORD-XML' }
  end

  describe "to_class_uri" do
    subject { described_class.to_class_uri }
    it { is_expected.to eq 'info:fedora/cm:VotingRecord' }
  end


  describe '#to_solr' do
    let(:record) { TuftsVotingRecord.new(pid: 'tufts:ny.someoffice.1', title: 'some title') }

    before do
      record.add_relationship(:has_model, 'info:fedora/cm:VotingRecord')
    end

    subject { record.to_solr }

    it 'sets object type as Dataset' do
      expect(subject['object_type_sim']).to eq ['Datasets']
    end
  end

end
