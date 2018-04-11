class AddHitsToRedPackets < ActiveRecord::Migration
  def change
    add_column :red_packets, :hits, :integer, default: 0
  end
end
