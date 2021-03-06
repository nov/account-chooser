class Account < ActiveRecord::Base
  attr_accessible :email, :name, :photo, :password, :password_confirmation
  has_secure_password

  attr_accessor :skip_password_validation

  has_many :open_ids

  validates :email,    presence: true, uniqueness: true
  validates :name,     presence: true
  validates :password, presence: {unless: :skip_password_validation}

  def skip_password_validation!
    self.password_digest ||= BCrypt::Password.create(SecureRandom.hex(16)).to_s
    self.skip_password_validation = true
  end

  class << self
    def authenticate(id_token) # for Google Identity Toolkit
      account = where(email: assertion[:email]).first_or_initialize
      account.name ||= [assertion[:lastName], assertion[:firstName]].join(' ')
      account.skip_password_validation!
      account.save && account
    end
  end
end
