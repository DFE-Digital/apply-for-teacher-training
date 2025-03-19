class WithdrawalRequest < ApplicationRecord
  belongs_to :application_choice
  belongs_to :provider_user

  enum :status, {
    draft: 'draft',
    requested: 'requested',
    cancelled: 'cancelled',
    auto_withdrawn: 'auto_withdrawn',
    withdrawn_by_candidate: 'withdrawn_by_candidate',
  }
end
