module CandidateInterface
  class WithdrawalFeedbackForm
    include ActiveModel::Model

    CONFIG_PATH = 'config/withdrawal_reasons.yml'.freeze

    attr_accessor :selected_reasons, :explanation
    validates :explanation, word_count: { maximum: 500 }

    def save(application_choice)
      if valid?
        application_choice.update!(
          structured_withdrawal_reasons: selected_reasons.compact_blank,
          withdrawal_feedback: {
            'Is there anything else you would like to tell us': explanation,
          },
        )
      else
        false
      end
    end

    def selectable_reasons
      YAML.load_file(CONFIG_PATH)
    end
  end
end
