require 'spec_helper'

describe BatchesHelper do
  before { @record = FactoryGirl.create(:tufts_pdf) }
  after  { @record.delete }

  describe 'for batch types that run jobs' do
    before do
      @batch = FactoryGirl.create(:batch_publish, pids: [@record.pid])
      @job = double({"time" => 1397575745, "uuid" => "1234",
                     "status" => "queued",
                     "options" => { "user_id" => 2,
                                    "record_id" => @record.pid,
                                    "batch_id" => @batch.id }
      })
    end

    after { @batch.delete }

    it '#line_item_status displays the job status' do
      status = helper.line_item_status(@batch, @job)
      expect(status).to match /queued/i
    end

    it '#item_count displays the number of jobs' do
      allow(@batch).to receive(:job_ids) { [@job.uuid] }
      expect(helper.item_count(@batch)).to eq 1
    end
  end

  describe "for batch types that don't run jobs" do
    before do
      @batch = FactoryGirl.create(:batch_template_import, pids: [@record.pid])
    end

    after { @batch.delete }

    describe '#line_item_status' do
      it 'displays the record status' do
        status = helper.line_item_status(@batch, nil, @record.pid)
        expect(status).to match /completed/i
      end

      it "has a default value if it can't figure out status" do
        status = helper.line_item_status(@batch, nil, 'non_existent_pid')
        expect(status).to match /Status not available/i
      end
    end

    describe '#item_count' do
      it 'displays the number of pids' do
        expect(helper.item_count(@batch)).to eq 1
      end

      it 'handles the case where pids is nil' do
        @batch.pids = nil
        expect(helper.item_count(@batch)).to eq 0
      end
    end
  end

end
