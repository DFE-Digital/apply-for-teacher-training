module CandidateInterface
  class PersonalStatement::InterviewPreferencesController < CandidateInterfaceController
    def edit
      @interview_preferences_form = InterviewPreferencesForm.build_from_application(
        current_application,
      )
    end

    def update
      @interview_preferences_form = InterviewPreferencesForm.new(interview_preferences_params)

      if @interview_preferences_form.save(current_application)
        render :show
      else
        render :edit
      end
    end

    def show
      @interview_preferences_form = current_application
    end

  private

    def interview_preferences_params
      params.require(:candidate_interface_interview_preferences_form).permit(
        :interview_preferences,
      )
    end
  end
end
