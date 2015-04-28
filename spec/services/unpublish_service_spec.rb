require 'spec_helper'

describe UnpublishService do
  let(:user) { FactoryGirl.create(:user) }

  describe '#run' do
    let(:obj) { TuftsImage.build_draft_version(title: 'My title', displays: ['dl']) }

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


  describe '.new' do
    let!(:draft) do
      obj = TuftsImage.build_draft_version(title: 'My title', displays: ['dl'])
      obj.save
      obj
    end

    let!(:published) do
      PublishService.new(draft).run
      draft.find_published
    end

    context 'when you pass it a draft object' do
      subject { UnpublishService.new(draft, user.id) }

      it 'assigns the object' do
        expect(subject.object).to eq draft
      end
    end

    context 'when you pass it a published object' do
      subject { UnpublishService.new(published, user.id) }

      it 'assigns the object to the draft version' do
        expect(subject.object).to eq draft
      end
    end
  end

end
