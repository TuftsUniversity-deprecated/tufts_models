require 'spec_helper'

module Job
  class MyJob
    include RunAsBatchItem
  end
end


describe Job::RunAsBatchItem do
  describe '#run_as_batch_item' do

    before do
      @batch_id = 123
      @old_batch_id = '456'
      @old_status = 'some existing status message'

      @pdf = FactoryGirl.create(:tufts_pdf, batch_id: @old_batch_id, qrStatus: [Reviewable.batch_review_text, @old_status])
      @job = Job::MyJob.new
    end

    after { @pdf.delete }

    it 'yields the record' do
      yielded = @job.run_as_batch_item(@pdf.id, @batch_id) do |record|
        record.pid
      end
      expect(yielded).to eq @pdf.pid
    end

    it 'adds batch id to the object without removing existing batch ids' do
      @job.run_as_batch_item(@pdf.id, @batch_id) do |record|
        record.save!
      end
      @pdf.reload
      expect(@pdf.batch_id).to eq [@old_batch_id, @batch_id.to_s]
    end

    it 'clears out the batch reviewed status marker' do
      @job.run_as_batch_item(@pdf.id, @batch_id) do |record|
        record.save!
      end
      @pdf.reload
      expect(@pdf.qrStatus).to eq [@old_status]
    end

    it "if the job itself marks the object as reviewed, the batch wrapper shouldn't clobber that status" do
      @job.run_as_batch_item(@pdf.id, @batch_id) do |record|
        record.reviewed
        record.save!
      end
      @pdf.reload
      expect(@pdf.qrStatus).to eq [@old_status, Reviewable.batch_review_text]
    end
  end

end
