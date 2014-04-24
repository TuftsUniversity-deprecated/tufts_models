class AddMetadataFileToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :metadata_file, :string
  end
end
