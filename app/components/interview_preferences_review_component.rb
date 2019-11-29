class InterviewPreferencesReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, editable: true, missing_error: false)
    @application_form = application_form
    @interview_preferences_form = CandidateInterface::InterviewPreferencesForm.build_from_application(
      @application_form,
    )
    @editable = editable
    @missing_error = missing_error
  end

  def interview_preferences_form_rows
    [interview_preferences_form_row]
  end

  def show_missing_banner?
    !@interview_preferences_form.valid? && @editable
  end

private

  attr_reader :application_form

  def interview_preferences_form_row
    {
      key: t('application_form.personal_statement.interview_preferences.key'),
      value: @interview_preferences_form.interview_preferences,
      action: t('application_form.personal_statement.interview_preferences.change_action'),
      change_path: Rails.application.routes.url_helpers.candidate_interface_interview_preferences_edit_path,
    }
  end
end
