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

  def visa_expiry_date
    application_form.visa_expired_at.to_fs(:govuk_date)
  end

  def how_will_you_complete_your_studies
    application_choice.pluck(:visa_explanation).map do |visa_explanation|
      I18n.t(
        "candidate_interface.visa_explanation_component.#{visa_explanation}",
      )
    end.to_sentence
  end

private

  def application_choices
    @application_choices ||= application_form
                               .application_choices
                               .where.not(sent_to_provider_at: nil)
                               .order(:sent_to_provider_at)
                               .reverse
  end
end
