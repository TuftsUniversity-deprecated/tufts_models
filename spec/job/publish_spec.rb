require 'spec_helper'

describe Job::Publish do
  let(:user_id) { '1' }
  let(:record_id) { 'pid:123' }
  subject { Job::Publish.new(user_id, record_id) }

  it 'uses the "publish" queue' do
    subject.queue_name.should == :publish
  end

  describe '#initialize' do
    it 'sets the user key' do
      subject.user_id.should == user_id
    end

    it 'sets the record id' do
      subject.record_id.should == record_id
    end
  end

  describe '#run' do
    it 'raises an error if it fails to find the object' do
      TuftsPdf.find(record_id).destroy if TuftsPdf.exists?(record_id)
      expect {
        subject.run
      }.to raise_error(ActiveFedora::ObjectNotFoundError)
    end

    it 'publishes the record' do
      record = FactoryGirl.create(:tufts_pdf)
      ActiveFedora::Base.should_receive(:find).with(record.id, cast: true).and_return(record)
      job = Job::Publish.new(user_id, record.id)
      record.should_receive(:push_to_production!).once
      job.run
      record.delete
    end
  end

end
