class AddUploadedFilesToBatches < ActiveRecord::Migration
  def change
    change_table(:batches) do |t|
      t.column :uploaded_files, :text
    end
  end
end
