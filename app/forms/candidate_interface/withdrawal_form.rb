module CandidateInterface
  class WithdrawalForm
    include ActiveModel::Model
    CONFIG_PATH = 'config/withdrawal_reasons.yml'.freeze

    attr_accessor :selected_reasons, :explanation
    validates :explanation, word_count: { maximum: 500 }
    validate :selected_reasons_presence

    def save(application_choice)
      if valid?
        ActiveRecord::Base.transaction do
          WithdrawApplication.new(application_choice: application_choice).save!

          application_choice.update!(
            structured_withdrawal_reasons: selected_reasons.compact_blank,
            withdrawal_feedback: {
              'Is there anything else you would like to tell us': explanation,
            },
          )
        end
      else
        false
      end
    end

    def selectable_reasons
      YAML.load_file(CONFIG_PATH)
    end

  private

    def selected_reasons_presence
      if selected_reasons.blank? || selected_reasons.compact_blank.blank?
        errors.add(:selected_reasons, :blank)
      end
    end
  end
end
