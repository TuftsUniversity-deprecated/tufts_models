class BatchPurge < Batch
  validates :pids, presence: true

  def display_name
    "Purge"
  end

end
