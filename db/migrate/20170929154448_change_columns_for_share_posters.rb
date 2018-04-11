class ChangeColumnsForSharePosters < ActiveRecord::Migration
  def change
    remove_index :share_posters, :card_id
    remove_column :share_posters, :card_id
    
    remove_index :share_posters, :receiver_hb_id
    remove_column :share_posters, :receiver_hb_id
    
    add_column :share_posters, :qrcode_other_configs, :string, default: '/dissolve/100/dx/10/dy/10'
    add_column :share_posters, :qrcode_text, :string
    add_column :share_posters, :text_pos, :string
    add_column :share_posters, :text_other_configs, :string, default: '/font/6buR5L2T/fontsize/640/fill/d2hpdGU=/dissolve/100/dx/10/dy/10'
  end
end
