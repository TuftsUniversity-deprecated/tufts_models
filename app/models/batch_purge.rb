class BatchPurge < Batch
  validates :pids, presence: true

  def display_name
    "Purge"
  end

  def run
    BatchRunnerService.new(self).run
  end
end
