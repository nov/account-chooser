class Account < ActiveRecord::Base
  attr_accessible :email, :name, :photo, :password, :password_confirmation
  has_secure_password

  validates :email,      presence: true, uniqueness: true
  validates :identifier,                 uniqueness: true, allow_nil: true
  validates :name,       presence: true
  validates :password,   presence: true, if: ->(this) { this.identifier.blank? }

  class << self
    def authenticate(assertion)
      account = where(email: assertion[:verifiedEmail]).first_or_initialize
      account.identifier = assertion[:identifier]
      account.name ||= assertion[:displayName]
      account.password_digest ||= BCrypt::Password.create(SecureRandom.hex(16)).to_s
      logger.info account.errors.full_messages unless account.valid?
      account.save && account
    end
  end
end
