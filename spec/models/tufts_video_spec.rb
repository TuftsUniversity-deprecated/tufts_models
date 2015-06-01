require 'spec_helper'

describe TuftsVideo do
  it 'has methods to support a draft version of the object' do
    expect(described_class).to respond_to(:build_draft_version)
  end

  describe "#default_datastream" do
    subject { described_class.default_datastream }
    it { is_expected.to eq 'Archival.video' }
  end

  describe '#to_solr' do
    subject { TuftsVideo.new(pid: 'tufts:ua236.001', title: 'some video') }

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
    subject { TuftsVideo.new(pid: 'tufts:ua236.001', title: 'some video') }

    it "doesn't allow you to upload an invalid type for a video" do
     expect(subject.valid_type_for_datastream?('Archival.video','image/png')).to eq false
    end

    it 'allows you to upload an valid type for a video' do
      expect(subject.valid_type_for_datastream?('Archival.video','video/mp4')).to eq true
    end
  end

  describe '#create_derivatives' do

    subject { FactoryGirl.build(:tufts_video) }

    before do
      TuftsVideo.find('tufts:v1').destroy if TuftsVideo.exists?('tufts:v1')
      subject.datastreams["Archival.video"].dsLocation = "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_video/sample.mp4"
      subject.datastreams["Archival.video"].mimeType = "video/mp4"
    end

    let(:webm_video_service) { double('webm-service') }
    let(:mp4_video_service) { double('mp4-service') }
    let(:thumbnail_service) { double('png-service') }

    it "uses the video generating service to create various derivatives" do
      expect(VideoGeneratingService).to receive(:new).with(subject, 'Access.webm', 'video/webm') { webm_video_service }

      expect(webm_video_service).to receive(:generate_access_webm).once


      expect(VideoGeneratingService).to receive(:new).with(subject, 'Access.mp4', 'video/mp4') { mp4_video_service }
      expect(mp4_video_service).to receive(:generate_access_mp4).once

      expect(VideoGeneratingService).to receive(:new).with(subject, 'Thumbnail.png', 'image/png') { thumbnail_service }
      expect(thumbnail_service).to receive(:generate_thumbnail).once


      subject.create_derivatives
    end
  end
end
