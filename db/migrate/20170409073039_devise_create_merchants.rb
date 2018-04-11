class DeviseCreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      ## Database authenticatable
      t.integer :merch_id
      t.string :mobile, null: false, default: ""
      # t.string :nickname
      # t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.string :name, null: false, default: ""
      t.string :intro
      t.string :address
      t.string :avatar
      t.string :private_token
      t.decimal :balance, precision: 16, scale: 2, default: 0.0
      t.integer :follows_count, default: 0
      t.integer :auth_type # 1 表示个人认证，2 表示企业认证，如果为空表示还没认证
      t.boolean :verified, default: true
      
      t.timestamps null: false
    end
    
    add_index :merchants, :mobile, unique: true
    add_index :merchants, :merch_id, unique: true
    add_index :merchants, :private_token, unique: true

    # add_index :merchants, :email,                unique: true
    add_index :merchants, :reset_password_token, unique: true
    # add_index :merchants, :confirmation_token,   unique: true
    # add_index :merchants, :unlock_token,         unique: true
  end
end
