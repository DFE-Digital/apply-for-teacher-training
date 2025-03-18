class WithdrawalRequest < ApplicationRecord
  belongs_to :application_choice
  belongs_to :provider_user

  CONFIG_PATH = 'config/withdrawal_request_reasons.yml'.freeze

  enum :status, {
    draft: 'draft',
    requested: 'requested',
    cancelled: 'cancelled',
    auto_withdrawn: 'auto_withdrawn',
    withdrawn_by_candidate: 'withdrawn_by_candidate',
  }

  def self.selectable_reasons
    YAML.load_file(CONFIG_PATH).fetch('withdrawal-request-reasons')
  end
end
