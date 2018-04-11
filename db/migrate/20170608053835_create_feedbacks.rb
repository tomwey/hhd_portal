class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :content, null: false, default: ''
      t.string :author

      t.timestamps null: false
    end
  end
end
