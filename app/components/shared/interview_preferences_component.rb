# NOTE: This component is used by both provider and support UIs
class InterviewPreferencesComponent < ApplicationComponent
  attr_reader :application_form
  delegate :interview_preferences, to: :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def rows
    rows = [{ key: t('application_form.interview_preferences.any_preferences.key'), value: interview_availability_message }]

    if application_form.interview_preferences.present?
      rows << { key: t('application_form.interview_preferences.details.key'), value: interview_preferences }
    end

    rows
  end

private

  def interview_availability_message
    if application_form.interview_preferences.present?
      'Yes'
    else
      'No'
    end
  end
end
