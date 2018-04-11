class AddQrcodeTicketToUserChannels < ActiveRecord::Migration
  def change
    add_column :user_channels, :qrcode_ticket, :string
  end
end
