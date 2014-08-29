require 'spec_helper'

describe Reviewable do
  subject { TuftsBase.new(title: 't', displays: ['dl']) }

  it 'uses a specific string to mark objects in a batch as reviewed' do
    expect(Reviewable.batch_review_text).to eq 'Batch Reviewed'
  end

  it 'knows if the object has been marked as reviewed' do
    expect(subject).to_not be_reviewed
    subject.qrStatus = [Reviewable.batch_review_text]
    expect(subject).to be_reviewed
  end

  it 'marks an object as reviewed' do
    subject.reviewed
    expect(subject.qrStatus).to eq [Reviewable.batch_review_text]
  end

  it "doesn't clobber existing status when it marks reviewed" do
    subject.qrStatus = ['status 1']
    subject.reviewed
    expect(subject.qrStatus).to eq ['status 1', Reviewable.batch_review_text]
  end

  it 'clears the batch reviewed status' do
    subject.qrStatus = ['status 1', Reviewable.batch_review_text]
    subject.clear_batch_review_text
    expect(subject.qrStatus).to eq ['status 1']
  end

end
