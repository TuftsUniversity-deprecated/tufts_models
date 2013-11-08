class AddSourceToDepositTypes < ActiveRecord::Migration
  def change
    add_column :deposit_types, :source, :string
  end
end
