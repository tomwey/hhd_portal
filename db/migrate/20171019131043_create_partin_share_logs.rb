class CreatePartinShareLogs < ActiveRecord::Migration
  def change
    create_table :partin_share_logs do |t|
      t.references :partin, index: true, null: false
      t.references :user, index: true, null: false
      t.string :ip
      t.st_point :location, geographic: true
      
      t.timestamps null: false
    end
    add_index :partin_share_logs, :location, using: :gist
    
  end
end
