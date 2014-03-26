class AddJobIdsToBatch < ActiveRecord::Migration
  def change
    change_table(:batches) do |t|
      t.column :job_ids, :text
    end
  end
end
