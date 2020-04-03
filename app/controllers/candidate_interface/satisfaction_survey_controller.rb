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
        render :recommendation
      end
    end

    def complexity
      @survey = SatisfactionSurveyForm.new
    end

    def submit_complexity
      @survey = SatisfactionSurveyForm.new(survey_params)

      if @survey.save(current_application)
        redirect_to candidate_interface_satisfaction_survey_ease_of_use_path
      else
        @survey = SatisfactionSurveyForm.new

        render :complexity
      end
    end

    def ease_of_use; end

  private

    def survey_params
      params.require(:candidate_interface_satisfaction_survey_form)
        .permit(:answer).merge!(question: get_question_asked_from_params)
    end

    def get_question_asked_from_params
      # removes 'submit_' from the controller action
      page_title = params['action'].split('_').drop(1).join('_')
      t("page_titles.#{page_title}")
    end
  end
end
