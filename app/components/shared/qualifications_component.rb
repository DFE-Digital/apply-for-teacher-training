# NOTE: This component is used by both provider and support UIs
class QualificationsComponent < ViewComponent::Base
  attr_reader :application_form, :application_choice_state, :show_hesa_codes

  alias show_hesa_codes? show_hesa_codes

  def initialize(application_form:, application_choice_state: nil, show_hesa_codes: false)
    @application_form = application_form
    @application_choice_state = application_choice_state
    @show_hesa_codes = show_hesa_codes
  end
end
