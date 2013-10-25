class RenameTuftsDepositTypeTable < ActiveRecord::Migration
  def change
    rename_table 'tufts_deposit_types', 'deposit_types'
  end
end
