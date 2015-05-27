class BatchExport < Batch
  validates :pids, presence: true

  def display_name
    "Export"
  end
end
