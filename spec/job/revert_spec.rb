require 'spec_helper'

describe Job::Revert do

  it 'uses the "revert" queue' do
    expect(Job::Revert.queue).to eq :revert
  end

  describe '::create' do
    let(:opts) do
      {record_id: '1',
        user_id: '1',
        batch_id: '1'}
    end

    it 'requires the user id' do
      opts.delete(:user_id)
      expect{Job::Revert.create(opts)}.to raise_exception(ArgumentError, /user_id/)
    end

    it 'requires the record id' do
      opts.delete(:record_id)
      expect{Job::Revert.create(opts)}.to raise_exception(ArgumentError, /record_id/)
    end

    it 'requires the batch id' do
      opts.delete(:batch_id)
      expect{Job::Revert.create(opts)}.to raise_exception(ArgumentError, /batch_id/)
    end
  end

  describe '#perform' do
    it 'raises an error if it fails to find the object in production' do
      pid = 'tufts:1'
      prod = Rubydora.connect(ActiveFedora.data_production_credentials)
      prod.purge_object(pid: pid) rescue RestClient::ResourceNotFound

      job = Job::Revert.new('uuid', 'record_id' => pid)
      expect{job.perform}.to raise_error(ActiveFedora::ObjectNotFoundError)
    end

    it 'reverts the record' do
      record = FactoryGirl.create(:tufts_pdf)
      record.publish!
      job = Job::Revert.new('uuid', 'record_id' => record.id)
      expect(TuftsBase).to receive(:revert_to_production).once
      job.perform
      record.delete
    end

    it 'can be killed' do
      record = FactoryGirl.create(:tufts_pdf)
      job = Job::Revert.new('uuid', 'user_id' => 1, 'record_id' => record.id)
      allow(job).to receive(:tick).and_raise(Resque::Plugins::Status::Killed)
      expect{job.perform}.to raise_exception(Resque::Plugins::Status::Killed)
    end

    it 'runs the job as a batch item' do
      pdf = FactoryGirl.create(:tufts_pdf)
      pdf.publish!
      batch_id = '10'
      job = Job::Revert.new('uuid', 'record_id' => pdf.id, 'user_id' => '1', 'batch_id' => batch_id)

      job.perform
      pdf.reload
      expect(pdf.batch_id).to eq [batch_id]

      pdf.delete
    end
  end
end
