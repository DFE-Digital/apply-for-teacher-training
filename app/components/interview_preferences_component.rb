class InterviewPreferencesComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def interview_preferences
    return application_form.interview_preferences if application_form.interview_preferences.present?

    'No preferences.'
  end
end
