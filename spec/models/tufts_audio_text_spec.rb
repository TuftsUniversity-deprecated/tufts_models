require 'spec_helper'

describe TuftsAudioText do

  describe "to_class_uri" do
    subject {TuftsAudioText}
    it "has sets the class_uri" do
      expect(subject.to_class_uri).to eq 'info:fedora/cm:Audio.OralHistory'
    end
  end

  it "should have an original_file_datastreams" do
    TuftsAudioText.original_file_datastreams.should == ['ARCHIVAL_XML', "ARCHIVAL_WAV"]
  end

  describe "an audio text with a pid" do
    before do
      subject.inner_object.pid = 'tufts:MS054.003.DO.02108'
    end
    it "should give a remote url" do
      subject.remote_url_for('ARCHIVAL_WAV', 'wav').should == 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MS054/archival_wav/MS054.003.DO.02108.archival.wav'
    end
    it "should give a local_path" do
      subject.local_path_for('ARCHIVAL_WAV', 'wav').should == File.expand_path("../../fixtures/local_object_store/data01/tufts/central/dca/MS054/archival_wav/MS054.003.DO.02108.archival.wav", __FILE__)
    end
    it "should give a remote url" do
      subject.remote_url_for('ARCHIVAL_XML', 'xml').should == 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MS054/archival_xml/MS054.003.DO.02108.archival.xml'
    end
    it "should give a local_path" do
      subject.local_path_for('ARCHIVAL_XML', 'xml').should == File.expand_path("../../fixtures/local_object_store/data01/tufts/central/dca/MS054/archival_xml/MS054.003.DO.02108.archival.xml", __FILE__)
    end
    it "should give a remote url" do
      subject.remote_url_for('ACCESS_MP3', 'mp3').should == 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MS054/access_mp3/MS054.003.DO.02108.access.mp3'
    end
    it "should give a local_path" do
      subject.local_path_for('ACCESS_MP3', 'mp3').should == File.expand_path("../../fixtures/local_object_store/data01/tufts/central/dca/MS054/access_mp3/MS054.003.DO.02108.access.mp3", __FILE__)
    end
  end

  # This tests depends on ffmpeg, so exlude it for travis
  describe "create_derivatives", :unless=> ENV["TRAVIS"] do
    before do
      subject.inner_object.pid = 'tufts:MISS.ISS.IPPI'
      subject.datastreams["ARCHIVAL_WAV"].dsLocation = "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_sound/MISS.ISS.IPPI.archival.wav"
    end
    describe "basic" do
      before { subject.create_derivatives }
      it "should create ACCESS_MP3" do
        File.exists?(subject.local_path_for('ACCESS_MP3', 'mp3')).should be_truthy
        subject.datastreams["ACCESS_MP3"].dsLocation.should == "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/access_mp3/MISS.ISS.IPPI.access.mp3"
        subject.datastreams["ACCESS_MP3"].mimeType.should == "audio/mpeg"
      end
    end
  end

end
