class ProviderInterface::FindCandidates::RightToWorkComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def visa_sponsorship_value
    if application_form.requires_visa_sponsorship?
      'Required'
    else
      'Not required'
    end
  end
end
