class InterviewPreferencesComponent < ViewComponent::Base
  delegate :interview_preferences, to: :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

private

  attr_reader :application_form
end
