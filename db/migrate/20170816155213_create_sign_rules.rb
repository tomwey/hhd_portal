class CreateSignRules < ActiveRecord::Migration
  def change
    create_table :sign_rules do |t|
      t.string :answer, null: false
      t.string :answer_from_tip, null: false
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :sign_rules, :user_id
  end
end
