module CandidateInterface
  class SatisfactionSurveyForm
    include ActiveModel::Model

    attr_accessor :question, :response

    def save(application_form)
      remove_strongly_agree_and_strongly_disagree_text(@response)
      application_form.update(satisfaction_survey: { @question => @response })
    end

  private

    def remove_strongly_agree_and_strongly_disagree_text(response)
      if response == '1 - strongly agree'
        @response = '1'
      elsif response == '5 - strongly disagree'
        @response = '5'
      end
    end
  end
end
