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
    let(:prod) { Rubydora.connect(ActiveFedora.data_production_credentials) }
    context 'record exists on staging and production' do
      it 'copys from production' do
        # exists on staging
        record = FactoryGirl.create(:tufts_pdf, title: "orig title")
        # exists on production
        record.publish!

        # make sure it reverts
        record.title = "changed title"
        record.save!
        Job::Revert.new('uuid', 'record_id' => record.pid).perform
        expect(record.reload.title).to eq "orig title"
      end
    end

    context 'record exists on staging, missing on production' do
      it 'hard deletes' do
        # exists on staging
        record = FactoryGirl.create(:tufts_pdf, title: "orig title")
        pid = record.pid
        # missing on production
        prod.purge_object(pid: pid) rescue RestClient::ResourceNotFound

        # make sure it hard deletes
        Job::Revert.new('uuid', 'record_id' => pid).perform
        expect(TuftsPdf.exists?(pid)).to be_falsey
      end
    end

    context 'record missing on staging, exists on production' do
      it 'copys from production' do
        # exists on production
        record = FactoryGirl.create(:tufts_pdf, title: "orig title")
        pid = record.pid
        record.publish!
        # missing on staging
        record.destroy

        # make sure it reverts
        Job::Revert.new('uuid', 'record_id' => pid).perform
        expect(TuftsPdf.find(pid).title).to eq "orig title"
      end
    end

    context 'record missing on staging and production' do
      it 'succeeds and does nothing' do
        pid = 'tufts:1'
        # missing on production
        prod.purge_object(pid: pid) rescue RestClient::ResourceNotFound
        # missing on staging
        TuftsPdf.find(pid).destroy if TuftsPdf.exists?(pid)

        # make sure it does nothing
        Job::Revert.new('uuid', 'record_id' => pid).perform
        expect(TuftsPdf.exists?(pid)).to be_falsey
      end
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
