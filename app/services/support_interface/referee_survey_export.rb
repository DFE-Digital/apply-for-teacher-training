module SupportInterface
  class RefereeSurveyExport
    def call
      references = ApplicationReference.where.not(questionnaire: nil)
      references_with_feedback = references.reject do |reference|
        reference.questionnaire.values.all? { |response| response == ' | ' }
      end

      output = []
      references_with_feedback.each do |reference|
        hash = {
          'Name' => reference.name,
          'Email_address' => reference.email_address,
          'Guidance rating' => extract_rating(reference, RefereeQuestionnaire::GUIDANCE_QUESTION),
          'Guidance explanation' => extract_explanation(reference, RefereeQuestionnaire::GUIDANCE_QUESTION),
          'Experience rating' => extract_rating(reference, RefereeQuestionnaire::EXPERIENCE_QUESTION),
          'Experience explanation' => extract_explanation(reference, RefereeQuestionnaire::EXPERIENCE_QUESTION),
          'Consent to be contacted' => extract_rating(reference, RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION),
          'Contact details' => extract_explanation(reference, RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION),
          'Safe to work with children?' => extract_rating(reference, RefereeQuestionnaire::SAFE_TO_WORK_WITH_CHILDREN_QUESTION),
          'Safe to work with children explanation' => extract_explanation(reference, RefereeQuestionnaire::SAFE_TO_WORK_WITH_CHILDREN_QUESTION),
        }

        output << hash
      end

      output
    end

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
