class AccountRecoveryRequest < ApplicationRecord
  belongs_to :candidate
  has_many :account_recovery_request_codes, dependent: :destroy
end
