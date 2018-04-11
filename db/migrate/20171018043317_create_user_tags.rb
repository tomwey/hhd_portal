class CreateUserTags < ActiveRecord::Migration
  def change
    create_table :user_tags do |t|
      t.integer :user_id, null: false
      t.integer :tag_id, null: false

      t.timestamps null: false
    end
    add_index :user_tags, :user_id
    add_index :user_tags, :tag_id
    add_index :user_tags, [:user_id, :tag_id], unique: true
  end
end
