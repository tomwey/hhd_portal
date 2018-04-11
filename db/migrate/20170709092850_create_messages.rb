class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :content, null: false
      t.integer :message_template_id
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :messages, :message_template_id
    add_index :messages, :user_id
  end
end
