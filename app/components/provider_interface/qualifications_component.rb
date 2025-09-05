class ProviderInterface::QualificationsComponent < ApplicationComponent
  attr_reader :application_form, :application_choice_state

  def initialize(application_form:, application_choice:)
    @application_form = application_form
    @application_choice = application_choice
    @application_choice_state = application_choice&.status
  end

  def render_degrees?
    @application_choice.present? && !@application_choice.teacher_degree_apprenticeship?
  end
end
