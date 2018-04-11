class CreateUserRedpacks < ActiveRecord::Migration
  def change
    create_table :user_redpacks do |t|
      t.references :user, index: true, foreign_key: true
      t.references :redpack, index: true, foreign_key: true
      t.integer :money

      t.timestamps null: false
    end
    
    add_index :user_redpacks, [:user_id, :redpack_id], unique: true
  end
end
