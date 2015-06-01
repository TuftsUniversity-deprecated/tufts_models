require 'spec_helper'

describe TuftsRCR do

  it 'has methods to support a draft version of the object' do
    expect(described_class).to respond_to(:build_draft_version)
  end

  describe "#default_datastream" do
    subject { described_class.default_datastream }
    it { is_expected.to eq 'RCR-CONTENT' }
  end

  describe "to_class_uri" do
    subject { described_class.to_class_uri }
    it { is_expected.to eq 'info:fedora/cm:Text.RCR' }
  end

  describe '#to_solr' do
    subject { TuftsVotingRecord.create(pid: 'tufts:RCR000001', title: 'some title') }

    before do
      subject.add_relationship(:has_model, 'info:fedora/cm:Text.RCR')
    end

    it 'sets object type as Dataset' do
      solr_doc = subject.to_solr
      expect(solr_doc['object_type_sim']).to eq ['Collection Creators']
    end
  end
end
