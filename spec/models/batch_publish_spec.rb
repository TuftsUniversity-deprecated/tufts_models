require 'spec_helper'

describe BatchPublish do
  subject { FactoryGirl.build(:batch_publish) }
  after { subject.delete if subject.persisted? }

  it 'has a display name' do
    expect(subject.display_name).to eq 'Publish'
  end

  it 'requires a list of pids' do
    subject.pids = nil
    expect(subject.valid?).to be_falsey
    expect(subject.errors[:pids]).to eq ["can't be blank"]
  end
end
