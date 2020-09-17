class QualificationsComponent < ViewComponent::Base
  attr_reader :application_form, :application_choice_state

  def initialize(application_form:, application_choice_state: nil)
    @application_form = application_form
    @application_choice_state = application_choice_state
  end
end
