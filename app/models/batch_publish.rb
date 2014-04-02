class BatchPublish < Batch
  validates :pids, presence: true

  def display_name
    "Publish"
  end

  def run
    return false unless valid?
    ids = pids.map do |pid|
      job = Job::Publish.create(user_id: creator.id, record_id: pid, batch_id: id)
    end
    update_attribute(:job_ids, ids)
  end

end
