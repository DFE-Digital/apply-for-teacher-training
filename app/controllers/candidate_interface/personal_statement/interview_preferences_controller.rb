module CandidateInterface
  class PersonalStatement::InterviewPreferencesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    after_action :complete_section, only: %i[update]

    def edit
      @interview_preferences_form = InterviewPreferencesForm.build_from_application(
        current_application,
      )
    end

    def update
      @interview_preferences_form = InterviewPreferencesForm.new(interview_preferences_params)

      if @interview_preferences_form.save(current_application)
        current_application.update!(interview_preferences_completed: false)

        redirect_to candidate_interface_interview_preferences_show_path
      else
        track_validation_error(@interview_preferences_form)
        render :edit
      end
    end

    def show
      @application_form = current_application
    end

    def complete
      current_application.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end

  private

    def interview_preferences_params
      params.require(:candidate_interface_interview_preferences_form).permit(
        :any_preferences, :interview_preferences
      )
        .transform_values(&:strip)
    end

    def application_form_params
      params.require(:application_form).permit(:interview_preferences_completed)
        .transform_values(&:strip)
    end

    def complete_section
      presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)

      if presenter.interview_preferences_completed? && !FeatureFlag.active?('mark_every_section_complete')
        current_application.update!(interview_preferences_completed: true)
      end
    end
  end
end
