module CandidateInterface
  class SatisfactionSurveyForm
    include ActiveModel::Model

    attr_accessor :question, :answer

    QUESTIONS_WE_ASK = [
      I18n.t('page_titles.recommendation'),
      I18n.t('page_titles.complexity'),
    ].freeze

    validates :question, presence: true
    validates :question, inclusion: { in: QUESTIONS_WE_ASK, allow_blank: false, message: 'Choose one of the options' }

    def save(application_form)
      return false unless valid?

      application_form.satisfaction_survey ||= {}
      application_form.satisfaction_survey[@question] = @answer
      application_form.save
    end

  private

    def question_already_answered?(application_form)
      application_form.satisfaction_survey&.keys&.include?(@question)
    end

    def merge_satisfaction_survey_and_answer(application_form)
      application_form.satisfaction_survey.merge!({ @question => @answer })
    end

    def question_already_answered?(application_form)
      application_form.satisfaction_survey&.keys&.include?(@question)
    end

    def merge_satisfaction_survey_and_response(application_form)
      application_form.satisfaction_survey.merge!({ @question => @response })
    end
  end
end
