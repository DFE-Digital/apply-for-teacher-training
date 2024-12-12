class WithdrawalReason < ApplicationRecord
  belongs_to :application_choice
  validates :reason, presence: true

  CONFIG_PATH = 'config/new_withdrawal_reasons.yml'.freeze

  def self.selectable_reasons
    YAML.load_file(CONFIG_PATH).fetch('withdrawal_reasons')
  end

  def self.find_reason_options(reason_ids_string = '')
    if reason_ids_string.empty?
      selectable_reasons
    else
      selectable_reasons.dig(*reason_ids_string.split('.'))
    end
  end
end
