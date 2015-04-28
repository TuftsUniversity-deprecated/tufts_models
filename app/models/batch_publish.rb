class BatchPublish < Batch
  validates :pids, presence: true

  def display_name
    "Publish"
  end

  def run
    BatchRunnerService.new(self).run
  end

end
