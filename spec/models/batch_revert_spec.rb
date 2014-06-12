require 'spec_helper'

describe BatchRevert do
  subject { FactoryGirl.build(:batch_revert) }
  after { subject.delete if subject.persisted? }

  it 'has a display name' do
    expect(subject.display_name).to eq 'Revert'
  end

  it 'requires a list of pids' do
    subject.pids = nil
    expect(subject.valid?).to be_falsey
    expect(subject.errors[:pids]).to eq ["can't be blank"]
  end

  it "only runs when it's valid, returns false if not valid" do
    invalid_batch = BatchRevert.new
    expect(invalid_batch.valid?).to be_falsey
    expect(invalid_batch.run).to be_falsey
  end

  it 'queues a revert job for each pid' do
    obj1 = FactoryGirl.create(:tufts_pdf)
    obj2 = FactoryGirl.create(:tufts_audio)

    batch = FactoryGirl.build(:batch_revert, pids: [obj1.id, obj2.id])

    job1 = double
    job2 = double

    expect(Job::Revert).to receive(:create).with(user_id: batch.creator.id, batch_id: batch.id, record_id: obj1.id) { job1 }
    expect(Job::Revert).to receive(:create).with(user_id: batch.creator.id, batch_id: batch.id, record_id: obj2.id) { job2 }

    return_value = batch.run
    expect(return_value).to be_truthy

    obj1.delete
    obj2.delete
  end

  it "saves the job ids" do
    batch = FactoryGirl.create(:batch_revert, pids: [1, 2, 3])
    allow(Job::Revert).to receive(:create).and_return(:a, :b, :c)

    batch.run
    expect(batch.job_ids).to eq [:a, :b, :c]
  end
end
