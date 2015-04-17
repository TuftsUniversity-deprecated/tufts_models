require 'spec_helper'

describe TuftsVideo do

  it 'has methods to support a draft version of the object' do
    expect(TuftsVideo.respond_to?(:build_draft_version)).to be_truthy
  end

  it "should have an original_file_datastreams" do
    expect(TuftsVideo.original_file_datastreams).to eq ['Archival.xml']
  end


  describe '#to_solr' do
    subject { TuftsTEI.create(pid: 'tufts:ms102.001', title: 'some title') }

    before do
      subject.add_relationship(:has_model, 'info:fedora/afmodel:TuftsVideo')
    end

    it 'sets object type as Video' do
      solr_doc = subject.to_solr
      expect(solr_doc['object_type_sim']).to eq ['Video']
    end
  end
end
