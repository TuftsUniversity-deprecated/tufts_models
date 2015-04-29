require 'spec_helper'

describe BatchPurge do
  subject { FactoryGirl.build(:batch_purge) }
  after { subject.delete if subject.persisted? }

  it 'requires a list of pids' do
    subject.pids = nil
    expect(subject.valid?).to be_falsey
    expect(subject.errors[:pids]).to eq ["can't be blank"]
  end
end
