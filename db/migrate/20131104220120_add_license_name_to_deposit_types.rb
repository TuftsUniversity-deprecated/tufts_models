class AddLicenseNameToDepositTypes < ActiveRecord::Migration
  def change
    add_column :deposit_types, :license_name, :string
  end
end
