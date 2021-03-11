module CandidateInterface
  class InterviewPreferencesReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true, missing_error: false, submitting_application: false)
      @application_form = application_form
      @interview_preferences_form = CandidateInterface::InterviewPreferencesForm.build_from_application(
        @application_form,
      )
      @editable = editable
      @missing_error = missing_error
      @submitting_application = submitting_application
    end

    def interview_preferences_form_rows
      [interview_preferences_form_row]
    end

    def show_missing_banner?
      !@application_form.interview_preferences_completed && @editable if @submitting_application
    end

  private

    attr_reader :application_form

    def interview_preferences_form_row
      preferences = @interview_preferences_form.interview_preferences.presence || t('application_form.personal_statement.interview_preferences.no_value')

      {
        key: t('application_form.personal_statement.interview_preferences.key'),
        value: preferences,
        action: t('application_form.personal_statement.interview_preferences.change_action'),
        change_path: candidate_interface_edit_interview_preferences_path,
      }
    end
  end
end
