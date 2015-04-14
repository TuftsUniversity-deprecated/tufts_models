require 'spec_helper'

describe TuftsVotingRecord do

  it 'has methods to support a draft version of the object' do
    expect(TuftsVotingRecord.respond_to?(:build_draft_version)).to be_truthy
  end

  it "should have an original_file_datastreams" do
    expect(TuftsVotingRecord.original_file_datastreams).to eq ['RECORD-XML']
  end

  describe "to_class_uri" do
    subject {TuftsVotingRecord}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:VotingRecord'
    end
  end

  describe '#to_solr' do
    subject { TuftsVotingRecord.create(pid: 'tufts:ny.someoffice.1', title: 'some title') }

    before do
      subject.add_relationship(:has_model, 'info:fedora/cm:VotingRecord')
    end

    it 'sets object type as Dataset' do
      solr_doc = subject.to_solr
      expect(solr_doc['object_type_sim']).to eq ['Datasets']
    end
  end

end
