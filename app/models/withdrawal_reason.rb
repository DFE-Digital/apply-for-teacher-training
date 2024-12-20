class WithdrawalReason < ApplicationRecord
  belongs_to :application_choice
  validates :reason, presence: true

  PERSONAL_CIRCUMSTANCES_KEY = 'personal-circumstances-have-changed'.freeze
  CONFIG_PATH = 'config/candidate_withdrawal_reasons.yml'.freeze

  enum :status, {
    draft: 'draft',
    published: 'published',
  }

  def publish!
    update!(status: 'published')
  end

  def self.selectable_reasons
    YAML.load_file(CONFIG_PATH).fetch('candidate-withdrawal-reasons')
  end

  def self.find_reason_options(reason = '')
    if reason.empty?
      selectable_reasons
    else
      selectable_reasons.dig(*reason.split('.'))
    end
  end
end
