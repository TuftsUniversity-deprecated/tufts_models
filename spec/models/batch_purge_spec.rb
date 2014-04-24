require 'spec_helper'

describe BatchPurge do
  subject { FactoryGirl.build(:batch_purge) }
  after { subject.delete if subject.persisted? }

  it 'requires a list of pids' do
    subject.pids = nil
    expect(subject.valid?).to be_false
    expect(subject.errors[:pids]).to eq ["can't be blank"]
  end

  it "only runs when it's valid, returns false if not valid" do
    invalid_batch = BatchPurge.new
    expect(invalid_batch.valid?).to be_false
    expect(invalid_batch.run).to be_false
  end

  it 'queues a purge job for each pid' do
    obj1 = FactoryGirl.create(:tufts_pdf)
    obj2 = FactoryGirl.create(:tufts_audio)

    batch = FactoryGirl.build(:batch_purge, pids: [obj1.id, obj2.id])

    job1 = double
    job2 = double

    expect(Job::Purge).to receive(:create).with(user_id: batch.creator.id, batch_id: batch.id, record_id: obj1.id) { job1 }
    expect(Job::Purge).to receive(:create).with(user_id: batch.creator.id, batch_id: batch.id, record_id: obj2.id) { job2 }

    return_value = batch.run
    expect(return_value).to be_true

    obj1.delete
    obj2.delete
  end

  it "saves the job ids" do
    batch = FactoryGirl.create(:batch_purge, pids: [1, 2, 3])
    allow(Job::Purge).to receive(:create).and_return(:a, :b, :c)

    batch.run
    expect(batch.job_ids).to eq [:a, :b, :c]
  end
end
