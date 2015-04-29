class BatchRevert < Batch
  validates :pids, presence: true

  def display_name
    "Revert"
  end
end
