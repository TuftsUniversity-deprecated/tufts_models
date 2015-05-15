require 'spec_helper'

describe VideoGeneratingService do

  describe 'generating various derivatives' do
    let(:video) { FactoryGirl.create(:tufts_video) }

    before(:all) do
      TuftsVideo.find('tufts:v1').destroy if TuftsVideo.exists?('tufts:v1')
    end

    before(:each) do
      video.datastreams["Archival.video"].dsLocation = "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_video/sample.mp4"
      video.datastreams["Archival.video"].mimeType = "video/mp4"
      video.save
    end

    describe "#generate_access_webm" do
      let(:derivative_id) { 'Access.webm' }
      let(:mime_type) { 'video/webm' }
      let(:video_service) { VideoGeneratingService.new(video, derivative_id, mime_type) }

      context "when the file exists" do
        it "generates the derivative" do
          file_path = LocalPathService.new(video, derivative_id).local_path
          FileUtils.rm_r(file_path, force: true)

          video_service.generate_access_webm

          expect(File.exists?(file_path)).to be_truthy
        end
      end

      it "raises an error if it the archival video doesn't exist" do
        video.datastreams['Archival.video'].dsLocation = 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_video/non-existant.mp4'
        video.save

        expect { video_service.generate_access_webm }.to raise_error(Errno::ENOENT)
      end

      it "raises an error if it doesn't have write permission to the derivatives folder" do
        derivative_path = LocalPathService.new(video, derivative_id).local_path

        with_unwritable_directory(derivative_path) do
          expect { video_service.generate_access_webm }.to raise_error(Errno::EACCES)
        end
      end

    end

    describe "#generate_thumbnail" do
      let(:derivative_id) { 'Thumbnail.png' }
      let(:mime_type) { 'image/png' }
      let(:video_service) { VideoGeneratingService.new(video, derivative_id, mime_type) }

      context "when the file exists" do
        it "generates the derivative" do
          file_path = LocalPathService.new(video, derivative_id).local_path
          FileUtils.rm_r(file_path, force: true)

          video_service.generate_thumbnail

          expect(File.exists?(file_path)).to be_truthy
        end
      end

      it "raises an error if it the archival video doesn't exist" do
        video.datastreams['Archival.video'].dsLocation = 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_video/non-existant.mp4'
        video.save

        expect { video_service.generate_thumbnail }.to raise_error(Errno::ENOENT)
      end

      it "raises an error if it doesn't have write permission to the derivatives folder" do
        derivative_path = LocalPathService.new(video, derivative_id).local_path

        with_unwritable_directory(derivative_path) do
          expect { video_service.generate_access_webm }.to raise_error(Errno::EACCES)
        end
      end

    end

    describe "#generate_access_mp4" do
      let(:derivative_id) { 'Access.mp4' }
      let(:mime_type) { 'video/mp4' }
      let(:video_service) { VideoGeneratingService.new(video, derivative_id, mime_type) }

      context "when the file exists" do
        it "generates the derivative" do
          file_path = LocalPathService.new(video, derivative_id).local_path
          FileUtils.rm_r(file_path, force: true)

          video_service.generate_access_webm

          expect(File.exists?(file_path)).to be_truthy
        end
      end

      it "raises an error if it the archival video doesn't exist" do
        video.datastreams['Archival.video'].dsLocation = 'http://bucket01.lib.tufts.edu/data01/tufts/central/dca/MISS/archival_video/non-existant.mp4'
        video.save

        expect { video_service.generate_thumbnail }.to raise_error(Errno::ENOENT)
      end

      it "raises an error if it doesn't have write permission to the derivatives folder" do
        derivative_path = LocalPathService.new(video, derivative_id).local_path

        with_unwritable_directory(derivative_path) do
          expect { video_service.generate_access_webm }.to raise_error(Errno::EACCES)
        end
      end

    end # generate_access_mp4

  end # generating derivatives

end
