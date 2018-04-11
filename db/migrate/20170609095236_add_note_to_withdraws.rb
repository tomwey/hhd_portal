class AddNoteToWithdraws < ActiveRecord::Migration
  def change
    add_column :withdraws, :note, :string
  end
end
