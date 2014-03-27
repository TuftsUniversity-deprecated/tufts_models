require 'spec_helper'

describe Batch do
  subject { Batch.new(pids: pids, job_ids: job_ids) }
  let(:job_ids) { [] }
  let(:pids) { [] }
  let(:jobs) do
    pids.zip(job_ids).map do |pid, uuid|
      double('uuid' => uuid,
       'options' => {'record_id' => pid})
    end
  end

  before do
    allow(Resque::Plugins::Status::Hash).to receive(:get) do |uuid|
      jobs.find{|j| j.uuid == uuid}
    end
  end

  it "requires a creator" do
    expect(subject.valid?).to be_false
  end

  it "requires children to implement ready?" do
    expect{Batch.new.ready?}.to raise_error(NotImplementedError)
  end

  it "requires children to implement run" do
    expect{Batch.new.run}.to raise_error(NotImplementedError)
  end

  it "saves pids correctly" do
    pids = ['a', 'b', 'c']
    id = FactoryGirl.create(:batch_template_update, pids: pids).id
    expect(Batch.find(id).pids).to eq pids
  end

  it "saves job ids correctly" do
    job_ids = ['a', 'b', 'c']
    id = FactoryGirl.create(:batch_template_update, job_ids: job_ids).id
    expect(Batch.find(id).job_ids).to eq job_ids
  end

  context "with some pids" do
    let(:pids) { ['tufts:1'] }
    let(:job_ids) { ['uuid:1'] }
    it "deletes related jobs and statuses when destroyed" do
      jobs.each do |job|
        expect(Resque::Plugins::Status::Hash).to receive(:kill).with(job.uuid)
        expect(Resque::Plugins::Status::Hash).to receive(:remove).with(job.uuid)
      end
      subject.save
      subject.destroy
    end
  end

  describe "#jobs" do
    let(:pids) { ['tufts:1'] }
    let(:job_ids) { ['uuid1'] }
    it "returns a list of job statuses" do
      expect(subject.jobs).to eq jobs
    end

    context "without job_ids" do
      let(:job_ids) { nil }
      it "returns an empty list" do
        expect(subject.jobs).to eq []
      end
    end
  end

  describe "#status" do
    it 'sets the batch status correctly' do
      {
        [:killed, :completed, :queued, :working, :failed, nil] => :not_available,
        [:killed, :completed, :queued, :working, :failed] => :failed,
        [:killed, :completed, :queued, :working] => :working,
        [:killed, :completed, :queued] => :queued,
        [:killed, :completed] => :completed,
        [:killed] => :killed
      }.each do |statuses, expected|
        allow(subject).to receive(:jobs) { statuses.map{|s| s.nil? ? nil : double(status: s)} }
        expect(subject.status).to eq(expected), "expected = #{expected.inspect}, job statuses = #{statuses.inspect}"
      end
    end
  end
end
