module CandidateInterface
  class InterviewPreferencesReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true, missing_error: false, submitting_application: false, return_to_application_review: false)
      @application_form = application_form
      @interview_preferences_form = CandidateInterface::InterviewPreferencesForm.build_from_application(
        @application_form,
      )
      @editable = editable
      @missing_error = missing_error
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
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
        action: {
          href: candidate_interface_edit_interview_preferences_path(return_to_params),
          visually_hidden_text: t('application_form.personal_statement.interview_preferences.change_action'),
        },
        html_attributes: {
          data: {
            qa: 'adjustments-interview-preferences',
          },
        },
      }
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
