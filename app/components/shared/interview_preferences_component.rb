# NOTE: This component is used by both provider and support UIs
class InterviewPreferencesComponent < ViewComponent::Base
  attr_reader :application_form
  delegate :interview_preferences, to: :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def rows
    rows = [{ key: 'Do you have any interview needs?', value: interview_needs_message }]

    if application_form.interview_preferences.present?
      rows << { key: 'What are your interview needs?', value: interview_preferences }
    end

    rows
  end

private

  def interview_needs_message
    if application_form.interview_preferences.present?
      'Yes'
    else
      'No'
    end
  end
end
