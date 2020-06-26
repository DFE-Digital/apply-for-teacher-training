module CandidateInterface
  class WithdrawalFeedbackForm
    include ActiveModel::Model

    attr_accessor :feedback, :explanation, :consent_to_be_contacted, :contact_details

    validates :feedback, :consent_to_be_contacted, presence: true
    validates :explanation, presence: true, if: :feedback?
    validates :contact_details, presence: true, if: :consent_to_be_contacted?

    def save(application_choice)
      if valid?
        questionnaire = {
          CandidateInterface::WithdrawalQuestionnaire::EXPLANATION_QUESTION => feedback,
          'Explanation' => explanation,
          CandidateInterface::WithdrawalQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => consent_to_be_contacted,
          'Contact details' => contact_details,
        }

        application_choice.update!(withdrawal_feedback: questionnaire)
      else
        false
      end
    end

  private

    def feedback?
      feedback == 'yes'
    end

    def consent_to_be_contacted?
      consent_to_be_contacted == 'yes'
    end
  end
end
