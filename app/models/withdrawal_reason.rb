class WithdrawalReason < ApplicationRecord
  belongs_to :application_choice
  validates :reason, presence: true

  PERSONAL_CIRCUMSTANCES_KEY = 'personal-circumstances-have-changed'.freeze
  CONFIG_PATH = 'config/candidate_withdrawal_reasons.yml'.freeze

  scope :by_level_one_reason, lambda { |level|
    keys = get_reason_options(level).map do |key, value|
      if value == {}
        key
      else
        value.map { |val_key, _| "#{key}.#{val_key}" }
      end
    end&.flatten

    where('reason LIKE ?', "#{level}%").sort do |a, b|
      keys.index(a.reason.gsub("#{level}.", '')) <=> keys.index(b.reason.gsub("#{level}.", ''))
    end
  }

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

  def self.get_reason_options(reason = '')
    if reason.empty?
      selectable_reasons
    else
      selectable_reasons.dig(*reason.split('.'))
    end
  end
end
