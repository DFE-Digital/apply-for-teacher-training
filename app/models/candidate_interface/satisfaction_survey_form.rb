module CandidateInterface
  class SatisfactionSurveyForm
    include ActiveModel::Model

    attr_accessor :question, :answer

    validates :question, presence: true

    def save(application_form)
      return false unless valid?

      remove_strongly_agree_and_strongly_disagree_text(@answer)
      application_form.update(satisfaction_survey: { @question => @answer })
    end

  private

    def remove_strongly_agree_and_strongly_disagree_text(answer)
      if answer == '1 - strongly agree'
        @answer = '1'
      elsif answer == '5 - strongly disagree'
        @answer = '5'
      end
    end
  end
end
