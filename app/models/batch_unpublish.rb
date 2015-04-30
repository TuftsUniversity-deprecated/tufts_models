class BatchUnpublish < Batch
  validates :pids, presence: true

  def display_name
    "Unpublish"
  end

end
