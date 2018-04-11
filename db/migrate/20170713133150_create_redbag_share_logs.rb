class CreateRedbagShareLogs < ActiveRecord::Migration
  def change
    create_table :redbag_share_logs do |t|
      t.references :redbag, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :ip
      t.st_point :location, geographic: true

      t.timestamps null: false
    end
    
    add_index :redbag_share_logs, :location, using: :gist
  end
end
