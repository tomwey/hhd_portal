class CreateTradeLogs < ActiveRecord::Migration
  def change
    create_table :trade_logs do |t|
      t.references :tradeable, polymorphic: true, index: true
      t.integer :user_id, index: true, null: false
      t.decimal :money, precision: 16, scale: 2, null: false
      t.string :title

      t.timestamps null: false
    end
  end
end
