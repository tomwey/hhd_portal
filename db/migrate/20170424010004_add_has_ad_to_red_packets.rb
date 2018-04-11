class AddHasAdToRedPackets < ActiveRecord::Migration
  def change
    add_column :red_packets, :has_ads, :boolean, default: true
  end
end
