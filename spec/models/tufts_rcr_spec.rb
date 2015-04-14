require 'spec_helper'

describe TuftsRCR do

  it 'has methods to support a draft version of the object' do
    expect(TuftsRCR.respond_to?(:build_draft_version)).to be_truthy
  end

  it "should have an original_file_datastreams" do
    expect(TuftsRCR.original_file_datastreams).to eq ['RCR-CONTENT']
  end
 
  describe "to_class_uri" do
    subject {TuftsRCR}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Text.RCR'
    end
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
