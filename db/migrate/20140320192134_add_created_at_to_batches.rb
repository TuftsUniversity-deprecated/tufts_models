class AddCreatedAtToBatches < ActiveRecord::Migration
  def change
    change_table(:batches) do |t|
      t.column :created_at, :datetime
    end
  end
end
