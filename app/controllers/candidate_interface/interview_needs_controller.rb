module CandidateInterface
  class InterviewNeedsController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def edit
      @interview_preferences_form = InterviewPreferencesForm.build_from_application(
        current_application,
      )
    end

    def update
      @interview_preferences_form = InterviewPreferencesForm.new(interview_preferences_params)

      if @interview_preferences_form.save(current_application)
        redirect_to candidate_interface_interview_preferences_show_path
      else
        track_validation_error(@interview_preferences_form)
        render :edit
      end
    end

    def show
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(completed: current_application.interview_preferences_completed)
    end

    def complete
      @section_complete_form = SectionCompleteForm.new(form_params)

      if @section_complete_form.save(current_application, :interview_preferences_completed)
        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def interview_preferences_params
      strip_whitespace params.require(:candidate_interface_interview_preferences_form).permit(
        :any_preferences, :interview_preferences
      )
    end

    def form_params
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end
  end
end
