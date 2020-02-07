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
        'experience_rating' => experience_rating,
        'experience_explanation' => experience_explanation,
        'guidance_rating' => guidance_rating,
        'guidance_explanation' =>  guidance_explanation,
        'safe_to_work_with_children' =>  safe_to_work_with_children,
        'safe_to_work_with_children_explanation' => (safe_to_work_with_children_explanation if safe_to_work_with_children == 'false'),
        'consent_to_be_contacted' => consent_to_be_contacted,
        'consent_to_be_contacted_details' => (consent_to_be_contacted_details if consent_to_be_contacted == 'true'),
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
  end
end
