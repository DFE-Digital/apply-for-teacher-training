class WithdrawalReason < ApplicationRecord
  belongs_to :application_choice
  validates :reason, presence: true
end
