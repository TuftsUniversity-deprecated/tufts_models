require 'spec_helper'

describe PublishService do
  describe '#run' do
    let(:user) { FactoryGirl.create(:user) }

    let(:obj) do
      TuftsImage.create(title: 'My title', displays: ['dl']).tap do |image|
        image.datastreams['Thumbnail.png'].dsLocation = "http://bucket01.lib.tufts.edu/data01/tufts/central/dca/UA136/thumb_png/UA136.002.DO.02673.thumbnail.png"
        image.save
      end
    end

    context "with a template" do
      let(:obj) { TuftsTemplate.create!(template_name: 'test template') }

      it "raises an error" do
        expect { PublishService.new(obj).run }.to raise_error UnpublishableModelError
      end
    end

    context "when a published version does not exist" do
      let(:published_pid) { PidUtils.to_published(obj.pid) }

      it "results in a published copy of the draft" do
        expect {
          PublishService.new(obj).run
        }.to change { TuftsImage.exists?(published_pid) }.from(false).to(true)

        published_obj = obj.find_published
        expect(published_obj).to be_published
        expect(published_obj.title).to eq 'My title'
        expect(published_obj.displays).to eq ['dl']
        expect(published_obj.datastreams['Thumbnail.png']).not_to be_new
      end
    end

    context "when a published version already exists" do
      let(:published_pid) { PidUtils.to_published(obj.pid) }
      before { PublishService.new(obj).run }

      it "replaces the existing published copy" do
        obj.update_attributes title: 'Edited title'
        PublishService.new(obj).run
        published_obj = obj.find_published
        expect(published_obj.title).to eq 'Edited title'
      end

    end


    it 'adds an entry to the audit log' do
      expect(AuditLogService).to receive(:log).with(user.user_key, obj.id, 'Pushed to production').once

      PublishService.new(obj, user.id).run
    end

    it 'results in the image being published' do
      expect(obj.published_at).to eq(nil)

      expect(obj).to_not be_published
      PublishService.new(obj).run
      obj.reload
      expect(obj).to be_published
    end

    it 'only updates the published_at time when actually published' do
      expect(obj.published_at).to eq nil

      PublishService.new(obj, user.id).run

      expect(obj.published_at).to_not be_nil
    end
  end
end
