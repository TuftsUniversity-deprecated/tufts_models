class BatchPublish < Batch
  validates :pids, presence: true
  serialize :pids

  def ready?
    valid?
  end

  def run
    return false unless ready?
    pids.each do |pid|
      job = Job::Publish.new(creator.id, pid)
      Tufts.queue.push(job)
    end
  end

end
