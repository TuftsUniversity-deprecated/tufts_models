class AddRecordTypeToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :record_type, :string
  end
end
