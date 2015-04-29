class AddScopeToSequences < ActiveRecord::Migration
  def change
    add_column :sequences, :scope, :string
  end
end
