module SupportInterface
  class RefereeSurveyExport
    def call
      non_duplicate_references = ApplicationReference
                                  .includes(:application_form)
                                  .where.not(questionnaire: nil)
                                  .where.not(duplicate: true)
      references_with_feedback = non_duplicate_references.find_each(batch_size: 100).reject do |reference|
        reference.questionnaire.values.all? { |response| response == ' | ' }
      end

      output = []
      references_with_feedback.each do |reference|
        hash = {
          reference_name: reference.name,
          reference_provided_at: reference.feedback_provided_at&.strftime('%d/%m/%y'),
          recruitment_cycle_year: reference.application_form.recruitment_cycle_year,
          reference_email_address: reference.email_address,
          guidance_rating: extract_rating(reference, RefereeQuestionnaire::GUIDANCE_QUESTION),
          guidance_explanation: extract_explanation(reference, RefereeQuestionnaire::GUIDANCE_QUESTION),
          experience_rating: extract_rating(reference, RefereeQuestionnaire::EXPERIENCE_QUESTION),
          experience_explanation: extract_explanation(reference, RefereeQuestionnaire::EXPERIENCE_QUESTION),
          consent_to_be_contacted: extract_rating(reference, RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION),
          contact_details: extract_explanation(reference, RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION),
        }

        output << hash
      end

      output
    end

    alias data_for_export call

  private

    def extract_rating(reference, field)
      get_response(reference.questionnaire[field]).first
    end

    def extract_explanation(reference, field)
      get_response(reference.questionnaire[field]).second
    end

    def get_response(response)
      response.split(' | ')
    end
  end
end
