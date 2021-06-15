module RefereeInterface
  class QuestionnaireForm
    include ActiveModel::Model

    FORM_KEYS = %i[
      experience_rating
      experience_explanation_very_poor
      experience_explanation_poor
      experience_explanation_ok
      experience_explanation_good
      experience_explanation_very_good

      guidance_rating
      guidance_explanation_very_poor
      guidance_explanation_poor
      guidance_explanation_ok
      guidance_explanation_good
      guidance_explanation_very_good

      consent_to_be_contacted
      consent_to_be_contacted_details
    ].freeze

    attr_accessor(*FORM_KEYS)

    def save(reference)
      questionnaire = {
        RefereeQuestionnaire::EXPERIENCE_QUESTION => "#{experience_rating} | #{experience_explanation}",
        RefereeQuestionnaire::GUIDANCE_QUESTION => "#{guidance_rating} | #{guidance_explanation}",
        RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => consent_to_be_contacted_response,
      }

      reference.update!(questionnaire: questionnaire, consent_to_be_contacted: consent_to_be_contacted)
    end

  private

    def experience_explanation
      case experience_rating
      when 'very_poor'
        experience_explanation_very_poor
      when 'poor'
        experience_explanation_poor
      when 'ok'
        experience_explanation_ok
      when 'good'
        experience_explanation_good
      when 'very_good'
        experience_explanation_very_good
      end
    end

    def guidance_explanation
      case guidance_rating
      when 'very_poor'
        guidance_explanation_very_poor
      when 'poor'
        guidance_explanation_poor
      when 'ok'
        guidance_explanation_ok
      when 'good'
        guidance_explanation_good
      when 'very_good'
        guidance_explanation_very_good
      end
    end

    def consent_to_be_contacted_response
      "#{consent_to_be_contacted} | #{consent_to_be_contacted_details if consent_to_be_contacted == 'true'}"
    end
  end
end
