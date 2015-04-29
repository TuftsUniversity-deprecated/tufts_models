class BatchRevert < Batch
  validates :pids, presence: true

  def display_name
    "Revert"
  end

  def run
    BatchRunnerService.new(self).run
  end
end
