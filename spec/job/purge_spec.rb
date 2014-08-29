require 'spec_helper'

describe Job::Purge do

  it 'uses the "purge" queue' do
    expect(Job::Purge.queue).to eq :purge
  end

  describe '::create' do
    let(:opts) do
      {record_id: '1',
        user_id: '1',
        batch_id: '1'}
    end

    it 'requires the user id' do
      opts.delete(:user_id)
      expect{Job::Purge.create(opts)}.to raise_exception(ArgumentError, /user_id/)
    end

    it 'requires the record id' do
      opts.delete(:record_id)
      expect{Job::Purge.create(opts)}.to raise_exception(ArgumentError, /record_id/)
    end

    it 'requires the batch id' do
      opts.delete(:batch_id)
      expect{Job::Purge.create(opts)}.to raise_exception(ArgumentError, /batch_id/)
    end
  end

  describe '#perform' do
    it 'raises an error if it fails to find the object' do
      obj_id = 'tufts:1'
      TuftsPdf.find(obj_id).destroy if TuftsPdf.exists?(obj_id)

      job = Job::Purge.new('uuid', 'user_id' => 1, 'record_id' => obj_id)
      expect{job.perform}.to raise_error(ActiveFedora::ObjectNotFoundError)
    end

    it 'purges the record' do
      record = FactoryGirl.create(:tufts_pdf)
      expect(ActiveFedora::Base).to receive(:find).with(record.id, cast: true).and_return(record)
      job = Job::Purge.new('uuid', 'user_id' => 1, 'record_id' => record.id)
      expect(record).to receive(:purge!).once
      job.perform
      record.delete
    end

    it 'can be killed' do
      record = FactoryGirl.create(:tufts_pdf)
      job = Job::Purge.new('uuid', 'user_id' => 1, 'record_id' => record.id)
      allow(job).to receive(:tick).and_raise(Resque::Plugins::Status::Killed)
      expect{job.perform}.to raise_exception(Resque::Plugins::Status::Killed)
    end

    it 'runs the job as a batch item' do
      pdf = FactoryGirl.create(:tufts_pdf)
      batch_id = '10'
      job = Job::Purge.new('uuid', 'record_id' => pdf.id, 'user_id' => '1', 'batch_id' => batch_id)

      job.perform
      pdf.reload
      expect(pdf.batch_id).to eq [batch_id]

      pdf.delete
    end

  end
end
