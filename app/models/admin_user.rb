class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         # :recoverable,
         :rememberable, :trackable, :validatable
  
  belongs_to :merchant
  
  validates :merchant_id, presence: true
  
end
