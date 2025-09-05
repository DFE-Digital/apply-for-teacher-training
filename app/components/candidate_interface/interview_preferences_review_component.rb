module CandidateInterface
  class InterviewPreferencesReviewComponent < ApplicationComponent
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
      [any_preferences_row].tap do |rows|
        rows << preference_details_row if @interview_preferences_form.interview_preferences.present?
      end
    end

    def show_missing_banner?
      !@application_form.interview_preferences_completed && @editable if @submitting_application
    end

  private

    attr_reader :application_form

    def any_preferences_row
      any_preferences = @interview_preferences_form.any_preferences&.capitalize || t('application_form.interview_preferences.no_value')

      {
        key: t('application_form.interview_preferences.any_preferences.key'),
        value: any_preferences,
        action: {
          href: candidate_interface_edit_interview_preferences_path(return_to_params),
          visually_hidden_text: t('application_form.interview_preferences.change_action'),
        },
        html_attributes: {
          data: {
            qa: 'adjustments-interview-preferences',
          },
        },
      }
    end

    def preference_details_row
      preference_details = @interview_preferences_form.interview_preferences.presence || t('application_form.interview_preferences.no_value')

      {
        key: t('application_form.interview_preferences.details.key'),
        value: preference_details,
        action: {
          href: candidate_interface_edit_interview_preferences_path(return_to_params),
          visually_hidden_text: t('application_form.interview_preferences.change_action'),
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
