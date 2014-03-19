class CreateBatch < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.references :creator
      t.string :template_id
      t.string :type
      t.text :pids
    end
  end
end
