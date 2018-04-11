class AddLocationAndRangeAndStartedAtToHongbaos < ActiveRecord::Migration
  def change
    add_column :hongbaos, :location, :st_point, geographic: true
    add_column :hongbaos, :range, :integer
    add_column :hongbaos, :started_at, :datetime
    add_index :hongbaos, :location, using: :gist
  end
end
