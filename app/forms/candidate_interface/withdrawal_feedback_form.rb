module CandidateInterface
  class WithdrawalFeedbackForm
    include ActiveModel::Model
    CONFIG_PATH = 'config/withdrawal_reasons.yml'.freeze

    attr_accessor :selected_reasons, :explanation

    validate :at_least_one_reason_selected

    def save(application_choice)
      if valid?
        application_choice.update!(
          structured_withdrawal_reasons: selected_reasons.compact_blank,
          withdrawal_feedback: {
            'Is there anything else you would like to ask': explanation,
          },
        )
      else
        false
      end
    end

    def selectable_reasons
      YAML.load_file(CONFIG_PATH)
    end

    def at_least_one_reason_selected
      if selected_reasons.compact_blank.empty?
        errors.add(:selected_reasons, 'Select at least one reason')
      end
    end
  end
end
