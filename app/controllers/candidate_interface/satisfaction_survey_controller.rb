module CandidateInterface
  class SatisfactionSurveyController < CandidateInterfaceController
    def recommendation
      @survey = SatisfactionSurveyForm.new
    end

    def submit_recommendation
      @survey = SatisfactionSurveyForm.new(survey_params)

      if @survey.save(current_application)
        redirect_to candidate_interface_satisfaction_survey_complexity_path
      else
        @survey = SatisfactionSurveyForm.new

        render :recommendation
      end
    end

    def complexity
      @survey = SatisfactionSurveyForm.new
    end

    def submit_complexity
      @survey = SatisfactionSurveyForm.new(survey_params)

      if @survey.save(current_application)
        redirect_to candidate_interface_satisfaction_survey_complexity_path
      else
        @survey = SatisfactionSurveyForm.new

        render :complexity
      end
    end

  private

    def survey_params
      params.require(:candidate_interface_satisfaction_survey_form)
        .permit(:question, :answer)
    end
  end
end
