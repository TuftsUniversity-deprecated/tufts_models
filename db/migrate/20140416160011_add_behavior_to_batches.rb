class AddBehaviorToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :behavior, :string
  end
end
