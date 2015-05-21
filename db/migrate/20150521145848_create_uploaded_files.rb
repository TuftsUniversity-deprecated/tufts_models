class CreateUploadedFiles < ActiveRecord::Migration
  def change
    create_table :uploaded_files do |t|
      t.references :batch, index: true
      t.string :pid
      t.string :dsid
      t.string :filename
    end
    remove_column :batches, :uploaded_files
  end
end
