class AddHbableToHongbaos < ActiveRecord::Migration
  def change
    add_reference :hongbaos, :hbable, polymorphic: true, index: true
  end
end
