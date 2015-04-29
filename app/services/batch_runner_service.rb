class BatchRunnerService
  attr_reader :batch
  def initialize(batch)
    @batch = batch
  end

  def run
    return false unless batch.valid?
    batch.update_attribute(:job_ids, create_jobs)
  end

  private

    def create_jobs
      batch.pids.map do |pid|
        job_type.create(user_id: batch.creator.id, record_id: pid, batch_id: batch.id)
      end
    end

    def job_type
      case batch
      when BatchRevert
        Job::Revert
      when BatchPublish
        Job::Publish
      when BatchPurge
        Job::Purge
      else
        raise "Unknown job type for #{batch.class}"
      end
    end
end
