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
  
  describe '#create_derivatives' do

    subject { FactoryGirl.create(:tufts_video) }

    before(:all) do
      TuftsVideo.find('tufts:v1').destroy if TuftsVideo.exists?('tufts:v1')
    end

    before(:each) do
      subject.datastreams["Archival.video"].dsLocation = "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_video/sample.mp4"
      subject.datastreams["Archival.video"].mimeType = "video/mp4"
      subject.save
    end

    it "raises an error if it the archival video doesn't exist" do
      subject.datastreams['Archival.video'].dsLocation = 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_video/non-existant.mp4'
      subject.save
      expect { subject.create_derivatives }.to raise_error(Errno::ENOENT)
    end

    it "raises an error if it doesn't have write permission to the derivatives folder" do
      webm_path = LocalPathService.new(subject, 'Access.webm').local_path
      webm_dirname = File.dirname(webm_path)

      FileUtils.mkdir_p(webm_dirname)  # in case the derivatives folder doesn't already exist
      FileUtils.chmod(0444, webm_dirname)

      expect { subject.create_derivatives }.to raise_error(Errno::EACCES)

      FileUtils.chmod(0755, File.dirname(webm_path))
    end

    it 'creates derivatives' do
      webm_path = LocalPathService.new(subject, 'Access.webm').local_path
      mp4_path = LocalPathService.new(subject, 'Access.mp4').local_path
      thumb_path = LocalPathService.new(subject, 'Thumbnail.png').local_path

      # remove previously generated derivatives, if any
      FileUtils.rm_r(webm_path, force: true)
      FileUtils.rm_r(mp4_path, force: true)
      FileUtils.rm_r(thumb_path, force: true)

      subject.create_derivatives

      expect(File.exists?(webm_path)).to be_truthy
      expect(File.exists?(mp4_path)).to be_truthy
      expect(File.exists?(thumb_path)).to be_truthy
    end

  end

end
