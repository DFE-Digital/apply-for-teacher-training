module RefereeInterface
  class QuestionnaireForm
    include ActiveModel::Model

    attr_accessor :experience_rating, :experience_explanation_very_poor, :experience_explanation_poor,
                  :experience_explanation_ok, :experience_explanation_good, :experience_explanation_very_good,
                  :guidance_rating, :guidance_explanation_very_poor,
                  :guidance_explanation_poor, :guidance_explanation_ok, :guidance_explanation_good,
                  :guidance_explanation_very_good, :safe_to_work_with_children,
                  :safe_to_work_with_children_explanation, :consent_to_be_contacted,
                  :consent_to_be_contacted_details

    def save(reference)
      questionnaire = {
        'Please rate your experience of giving a reference' => "#{experience_rating} | #{experience_explanation}",
        'Please rate how useful our guidance was' => "#{guidance_rating} | #{guidance_explanation}",
        'If we asked whether a candidate was safe to work with children, would you feel able to answer?' => safe_to_work_with_children_response,
        'Can we contact you about your experience of giving a reference?' => consent_to_be_contacted_response,
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

    def safe_to_work_with_children_response
      "#{safe_to_work_with_children} | #{(safe_to_work_with_children_explanation if safe_to_work_with_children == 'false')}"
    end

    def consent_to_be_contacted_response
      "#{consent_to_be_contacted} | #{(consent_to_be_contacted_details if consent_to_be_contacted == 'true')}"
    end
  end
end
