class BatchPublish < Batch
  validates :pids, presence: true
  serialize :pids

  def ready?
    valid?
  end

  def run
    return false unless ready?
    pids.map do |pid|
      job = Job::Publish.create(user_id: creator.id, record_id: pid)
    end
  end

end
