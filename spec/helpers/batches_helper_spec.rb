require 'spec_helper'

describe BatchesHelper do
  before { @record = FactoryGirl.create(:tufts_pdf) }
  after  { @record.delete }

  describe '#line_item_status' do
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

      it 'displays the job status' do
        status = helper.line_item_status(@batch, @job)
        expect(status).to match /queued/i
      end
    end

    describe "for batch types that don't run jobs" do
      before do
        @batch = FactoryGirl.create(:batch_template_import, pids: [@record.pid])
      end

      after { @batch.delete }

      it 'displays the record status' do
        status = helper.line_item_status(@batch, nil, @record.pid)
        expect(status).to match /completed/i
      end

      it "has a default value if it can't figure out status" do
        status = helper.line_item_status(@batch, nil, 'non_existent_pid')
        expect(status).to match /Status not available/i
      end
    end
  end

end
