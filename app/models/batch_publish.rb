class BatchPublish < Batch
  validates :pids, presence: true

  def display_name
    "Publish"
  end
end
