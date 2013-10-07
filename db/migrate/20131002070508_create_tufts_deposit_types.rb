class CreateTuftsDepositTypes < ActiveRecord::Migration
  def change
    create_table :tufts_deposit_types do |t|
      t.string :display_name
      t.text :deposit_agreement

      t.timestamps
    end
  end
end
