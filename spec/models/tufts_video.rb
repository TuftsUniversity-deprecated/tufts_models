require 'spec_helper'

describe TuftsVideo do

  it 'has methods to support a draft version of the object' do
    expect(TuftsVideo.respond_to?(:build_draft_version)).to be_truthy
  end

  it "should have an original_file_datastreams" do
    expect(TuftsVideo.original_file_datastreams).to eq ['ARCHIVAL_XML','Archival.video']
  end


  describe '#to_solr' do
    subject { TuftsVideo.create(pid: 'tufts:ua236.001', title: 'some video') }

    before do
      subject.add_relationship(:has_model, 'info:fedora/afmodel:TuftsVideo')
      subject.datastreams['ARCHIVAL_XML'].dsLocation  = "http://example.com/example.xml"
    end

    it 'sets object type as Video' do
      solr_doc = subject.to_solr
      expect(solr_doc['object_type_sim']).to eq ['Video','Text']
    end
  end

  describe "#valid_type_for_datastream?" do
    subject { TuftsVideo.create(pid: 'tufts:ua236.001', title: 'some video') }

    it 'should not allow you to upload an invalid type for a video' do
     expect(subject.valid_type_for_datastream?('Archival.video','image/png')).to eq false
    end

    it 'should allow you to upload an valid type for a video' do
      expect(subject.valid_type_for_datastream?('Archival.video','video/mp4')).to eq true
    end
  end
end
