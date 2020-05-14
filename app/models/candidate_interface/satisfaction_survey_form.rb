module CandidateInterface
  class SatisfactionSurveyForm
    include ActiveModel::Model

    attr_accessor :question, :answer

    validates :question, presence: true
    validates :question, inclusion: { in: SatisfactionSurvey::QUESTIONS_WE_ASK, allow_blank: false, message: 'Choose one of the options' }

    def save(application_form)
      return false unless valid?

      application_form.satisfaction_survey ||= {}
      application_form.satisfaction_survey[@question] = @answer
      application_form.save
    end
  end
end
