class AccountRecoveryRequest < ApplicationRecord
  belongs_to :candidate
  has_many :codes, class_name: 'AccountRecoveryRequestCode', dependent: :destroy

  normalizes :previous_account_email_address, with: ->(email) { email.downcase.strip }
end
