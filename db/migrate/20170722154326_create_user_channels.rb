class CreateUserChannels < ActiveRecord::Migration
  def change
    create_table :user_channels do |t|
      t.string :name
      t.string :address
      t.integer :uniq_id
      t.integer :users_count, default: 0
      t.string :mobile

      t.timestamps null: false
    end
  end
end
