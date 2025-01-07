class WithdrawalReason < ApplicationRecord
  belongs_to :application_choice
  validates :reason, presence: true

  PERSONAL_CIRCUMSTANCES_KEY = 'personal-circumstances-have-changed'.freeze
  CONFIG_PATH = 'config/candidate_withdrawal_reasons.yml'.freeze

  scope :by_level, lambda { |level|
    where('reason LIKE ?', "#{level}%").sort do |a, b|
      all_reasons.index(a.reason) <=> all_reasons.index(b.reason)
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

  def self.all_reasons
    selectable_reasons.map do |key, value|
      build_reason(key, value)
    end&.flatten
  end

  def self.build_reason(key, value)
    if value == {}
      key
    else
      value.map { |k, v| build_reason("#{key}.#{k}", v) }
    end
  end
end
