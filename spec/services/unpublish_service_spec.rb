require 'spec_helper'

describe UnpublishService do
  describe '#run' do
    let(:obj) { TuftsImage.build_draft_version(title: 'My title', displays: ['dl']) }
    let(:user) { FactoryGirl.create(:user) }

    before do
      obj.save
      PublishService.new(obj).run
    end

    it "deletes the published copy, retains the draft, and logs the action" do
      expect(AuditLogService).to receive(:log).with(user.user_key, obj.id, 'Unpublished').once
      UnpublishService.new(obj, user.id).run
      expect { obj.find_published }.to raise_error ActiveFedora::ObjectNotFoundError
      expect(obj.find_draft).not_to be_published
    end
  end
end
