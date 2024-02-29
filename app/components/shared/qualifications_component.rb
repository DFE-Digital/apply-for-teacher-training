# NOTE: This component is used by both provider and support UIs
class QualificationsComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :application_form, :application_choice_state, :show_hesa_codes

  alias show_hesa_codes? show_hesa_codes

  def initialize(application_form:, application_choice: nil, show_hesa_codes: false)
    @application_form = application_form
    @show_hesa_codes = show_hesa_codes
    @application_choice = application_choice
    @application_choice_state = application_choice&.status
  end

  def render_degrees?
    current_namespace == 'support_interface' ||
      (current_namespace == 'provider_interface' && @application_choice && !@application_choice.degree_apprenticeship?)
  end

  def editable?
    application_form.editable? && current_namespace == 'support_interface'
  end
end
