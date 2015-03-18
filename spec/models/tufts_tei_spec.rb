require 'spec_helper'

describe TuftsTEI do
  it "should have an original_file_datastreams" do
    expect(TuftsTEI.original_file_datastreams).to eq ['Archival.xml']
  end
 
  describe "to_class_uri" do
    subject {TuftsTEI}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Text.TEI'
    end
  end

  describe '#to_solr' do
    subject { TuftsTEI.create(pid: 'tufts:ms102.001', title: 'some title') }

    before do
      subject.add_relationship(:has_model, 'info:fedora/cm:Text.TEI')
    end

    it 'sets object type as Text' do
      solr_doc = subject.to_solr
      expect(solr_doc['object_type_sim']).to eq ['Text']
    end
  end
end
