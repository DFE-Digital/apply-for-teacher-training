module CandidateInterface
  class SatisfactionSurveyForm
    include ActiveModel::Model

    attr_accessor :question, :answer

    validates :question, presence: true

    def save(application_form)
      return false unless valid?

      if question_already_answered?(application_form)
        application_form.satisfaction_survey[@question] = @answer
        application_form.save
      elsif application_form.satisfaction_survey.present?
        application_form.update!(satisfaction_survey: merge_satisfaction_survey_and_answer(application_form))
      else
        application_form.update!(satisfaction_survey: { @question => @answer })
      end
    end

  private

    def question_already_answered?(application_form)
      application_form.satisfaction_survey&.keys&.include?(@question)
    end

    def merge_satisfaction_survey_and_answer(application_form)
      application_form.satisfaction_survey.merge!({ @question => @answer })
    end
  end
end
