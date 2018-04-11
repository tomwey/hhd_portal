class CreateMerchantTags < ActiveRecord::Migration
  def change
    create_table :merchant_tags do |t|
      t.integer :uniq_id
      t.string :name, null: false, default: ''
      t.references :merchant, index: true, null: false

      t.timestamps null: false
    end
    add_index :merchant_tags, :uniq_id, unique: true
  end
end
