class AddBodyImageAndCardIdToSharePoster < ActiveRecord::Migration
  def change
    add_column :share_posters, :qrcode_pos, :string
    add_column :share_posters, :body_image, :string
    add_column :share_posters, :card_id, :integer
    add_index :share_posters, :card_id
  end
end
