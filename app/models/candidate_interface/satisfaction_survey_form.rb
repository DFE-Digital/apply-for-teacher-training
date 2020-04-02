module CandidateInterface
  class SatisfactionSurveyForm
    include ActiveModel::Model

    attr_accessor :question, :answer

    validates :question, presence: true

    def save(application_form)
      return false unless valid?

      application_form.update(satisfaction_survey: { @question => @answer })
    end
  end
end
