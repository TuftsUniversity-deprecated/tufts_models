require 'spec_helper'

describe RevertService do
  describe '#run' do
    subject { TuftsImage.build_draft_version(title: 'My title', displays: ['dl']) }
    let(:user) { FactoryGirl.create(:user) }
    let(:draft_pid) { PidUtils.to_draft(subject.pid) }
    let(:published_pid) { PidUtils.to_published(subject.pid) }

    context "when the draft and published version exists" do
      before do
        subject.save!
        PublishService.new(subject).run
      end

      it "reverts the draft to the published version" do
        published_version = subject.find_published

        subject.title = "new title"
        subject.save

        RevertService.new(subject).run

        expect(subject.reload.title).to eq("My title")
      end

      it "ensures the solr index is updated afterwards" do
        expect(subject).to receive(:update_index).once { true }
        RevertService.new(subject).run
      end
    end
  end
end
