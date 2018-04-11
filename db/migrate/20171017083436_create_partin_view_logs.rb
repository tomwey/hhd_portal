class CreatePartinViewLogs < ActiveRecord::Migration
  def change
    create_table :partin_view_logs do |t|
      t.references :partin, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :ip
      t.st_point :location, geographic: true
      t.integer :from_type, default: 0 # 0表示来自ionic app端

      t.timestamps null: false
    end
    
    add_index :partin_view_logs, :location, using: :gist
    
  end
end
