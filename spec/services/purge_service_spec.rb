require 'spec_helper'

describe PurgeService do
  describe '#run' do
    subject { TuftsImage.build_draft_version(title: 'My title', displays: ['dl']) }

    let(:user) { FactoryGirl.create(:user) }
    let(:draft_pid) { PidUtils.to_draft(subject.pid) }
    let(:published_pid) { PidUtils.to_published(subject.pid) }

    context "when only the published version exists" do
      # not a very likely scenario
      before do
        subject.save!
        PublishService.new(subject).run
        subject.destroy
      end

      it "hard-deletes the published version" do
        expect(TuftsImage.exists?(published_pid)).to be_truthy

        PurgeService.new(subject).run

        expect(TuftsImage.exists?(published_pid)).to be_falsey
      end

      it "creates an audit log" do
        expect(AuditLogService).to receive(:log).with(user.user_key, subject.id, "Purged published version").once
        expect(AuditLogService).to receive(:log).with(user.user_key, subject.id, "Purged draft version").never
        PurgeService.new(subject, user).run
      end
    end

    context "when the draft version exists" do
      before do
        subject.save!
      end

      it "hard-deletes the draft version" do
        expect(TuftsImage).to exist(draft_pid)
        PurgeService.new(subject).run
        expect(TuftsImage).not_to exist(draft_pid)
      end

      it "creates an audit log" do
        expect(AuditLogService).to receive(:log).with(user.user_key, subject.id, "Purged published version").never
        expect(AuditLogService).to receive(:log).with(user.user_key, subject.id, "Purged draft version").once

        PurgeService.new(subject, user).run
      end
    end

    context "when both versions exist" do
      before do
        subject.save!
        PublishService.new(subject).run
      end

      it "hard-deletes both versions" do
        expect(TuftsImage).to exist(draft_pid)
        expect(TuftsImage).to exist(published_pid)

        PurgeService.new(subject).run

        expect(TuftsImage).not_to exist(draft_pid)
        expect(TuftsImage).not_to exist(published_pid)
      end

      it "creates an audit log" do
        expect(AuditLogService).to receive(:log).with(user.user_key, subject.id, "Purged published version").once
        expect(AuditLogService).to receive(:log).with(user.user_key, subject.id, "Purged draft version").once

        PurgeService.new(subject, user).run
      end
    end
  end
end

