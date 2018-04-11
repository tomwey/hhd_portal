class CreateBanners < ActiveRecord::Migration
  def change
    create_table :banners do |t|
      t.integer :uniq_id
      t.string  :image, null: false
      t.string  :link
      t.integer :view_count,  default: 0
      t.integer :click_count, default: 0
      t.boolean :opened, default: true
      t.integer :sort, default: 0

      t.timestamps null: false
    end
  end
end
