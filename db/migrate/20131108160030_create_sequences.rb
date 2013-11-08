class CreateSequences < ActiveRecord::Migration
  def change
    create_table :sequences do |t|
      t.column :value, :integer, default: 0
    end
  end
end
