class RemoveSourceFromDepositTypes < ActiveRecord::Migration
  def change
    remove_column :deposit_types, :source, :string
  end
end
