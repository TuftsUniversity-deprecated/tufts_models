class BatchPublish < Batch
  validates :pids, presence: true

  def ready?
    valid?
  end

  def run
    return false unless ready?
    ids = pids.map do |pid|
      job = Job::Publish.create(user_id: creator.id, record_id: pid)
    end
    update_attribute(:job_ids, ids)
  end

end
