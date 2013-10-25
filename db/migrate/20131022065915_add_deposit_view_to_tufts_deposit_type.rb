class AddDepositViewToTuftsDepositType < ActiveRecord::Migration
  def change
    add_column :tufts_deposit_types, :deposit_view, :string
  end
end
