class CreateQuizRules < ActiveRecord::Migration
  def change
    create_table :quiz_rules do |t|
      t.string :question, null: false, default: ''
      t.string :answers, array: true, default: []
      t.string :answer, null: false, default: ''
      t.string :memo

      t.timestamps null: false
    end
  end
end
