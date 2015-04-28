require 'spec_helper'

describe BatchTemplateUpdateRunnerService do
  describe '#create_jobs' do
    let(:batch) { FactoryGirl.build(:batch_template_update, id: 10, pids: ['tufts:1', 'tufts:2', 'tufts:3']) }
    let(:runner) { described_class.new(batch) }
    let(:attrs) { { filesize: ['57 MB'] } }

    it 'queues one job for each record' do
      args = { user_id: batch.creator_id, attributes: attrs, batch_id: 10 }
      expect(Job::ApplyTemplate).to receive(:create).with(args.merge(record_id: "draft:1"))
      expect(Job::ApplyTemplate).to receive(:create).with(args.merge(record_id: "draft:2"))
      expect(Job::ApplyTemplate).to receive(:create).with(args.merge(record_id: "draft:3"))

      runner.send(:create_jobs, attrs)
    end

    it "returns a list of job ids" do
      allow(Job::ApplyTemplate).to receive(:create).and_return(:a, :b, :c)

      expect(runner.send(:create_jobs, attrs)).to eq [:a, :b, :c]
    end
  end
end
