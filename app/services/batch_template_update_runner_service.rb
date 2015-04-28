class BatchTemplateUpdateRunnerService < BatchRunnerService
  attr_reader :batch
  def initialize(batch)
    @batch = batch
  end

  def run
    return false unless batch.valid?
    attributes = TuftsTemplate.find(batch.template_id).attributes_to_update
    return if attributes.empty?

    (ids = create_jobs(attributes)) && batch.update_attribute(:job_ids, ids)
  end

  private

    def create_jobs(attributes)
      batch.pids.map do |record_id|
        job_type.create(user_id: batch.creator.id, record_id: PidUtils.to_draft(record_id),
                                  attributes: attributes, batch_id: batch.id)
      end
    end


    def job_type
      Job::ApplyTemplate
    end
end

