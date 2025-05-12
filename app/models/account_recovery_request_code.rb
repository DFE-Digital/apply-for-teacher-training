class AccountRecoveryRequestCode < ApplicationRecord
  belongs_to :account_recovery_request
  has_secure_password :code, validations: false

  validates :code, presence: true

  scope :not_expired, -> { where('created_at >= ?', 15.minutes.ago) }

  def self.generate_code
    Array.new(6) { rand(0..9) }.join
  end
end
