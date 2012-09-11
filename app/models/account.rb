class Account < ActiveRecord::Base
  attr_accessible :email, :name, :photo, :password, :password_confirmation
  has_secure_password

  validates :email,    presence: true, uniqueness: true
  validates :name,     presence: true
  validates :password, presence: true
end
