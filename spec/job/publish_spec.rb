require 'spec_helper'

describe Job::Publish do
  let(:user_id) { '1' }
  let(:record_id) { 'pid:123' }
  subject { Job::Publish.new(user_id, record_id) }

  it 'uses the "publish" queue' do
    expect(Job::Publish.queue).to eq :publish
  end

  describe '::create' do
    it 'requires the user id' do
      expect{Job::Publish.create('record_id' => '1')}.to raise_exception(ArgumentError)
    end

    it 'requires the record id' do
      expect{Job::Publish.create('user_id' => '1')}.to raise_exception(ArgumentError)
    end
  end

  describe '#perform' do
    it 'raises an error if it fails to find the object' do
      obj_id = 'tufts:1'
      TuftsPdf.find(obj_id).destroy if TuftsPdf.exists?(obj_id)

      job = Job::Publish.new('uuid', 'user_id' => 1, 'record_id' => obj_id)
      expect{job.perform}.to raise_error(ActiveFedora::ObjectNotFoundError)
    end

    it 'publishes the record' do
      record = FactoryGirl.create(:tufts_pdf)
      ActiveFedora::Base.should_receive(:find).with(record.id, cast: true).and_return(record)
      job = Job::Publish.new('uuid', 'user_id' => 1, 'record_id' => record.id)
      record.should_receive(:push_to_production!).once
      job.perform
      record.delete
    end
  end

end
