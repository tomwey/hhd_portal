class CreatePayLogs < ActiveRecord::Migration
  def change
    create_table :pay_logs do |t|
      t.string :uniq_id
      t.references :merchant, index: true, foreign_key: true, null: false
      t.integer :money, null: false
      t.string :title
      t.references :payable, polymorphic: true, index: true

      t.timestamps null: false
    end
    add_index :pay_logs, :uniq_id, unique: true
  end
end
