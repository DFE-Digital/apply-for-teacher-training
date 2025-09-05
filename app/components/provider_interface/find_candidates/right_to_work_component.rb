class ProviderInterface::FindCandidates::RightToWorkComponent < ApplicationComponent
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def visa_sponsorship_value
    if application_form.requires_visa_sponsorship?
      t('.required')
    else
      t('.not_required')
    end
  end

  def visa_status_value
    if application_form.british_or_irish?
      t('.british_or_irish')
    else
      t(".#{application_form.immigration_status.presence || 'unknown'}")
    end
  end
end
