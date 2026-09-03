class ProviderInterface::FindCandidates::RightToWorkComponent < ApplicationComponent
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def visa_sponsorship_value
    if application_form.requires_visa_sponsorship?
      t('provider_interface.find_candidates.right_to_work_component.required')
    else
      t('provider_interface.find_candidates.right_to_work_component.not_required')
    end
  end

  def visa_status_value
    if application_form.british_or_irish?
      t('provider_interface.find_candidates.right_to_work_component.british_or_irish')
    else
      t("provider_interface.find_candidates.right_to_work_component.#{application_form.immigration_status.presence || 'unknown'}")
    end
  end

  def visa_expiry_date
    application_form.visa_expired_at.to_fs(:govuk_date)
  end

  def how_will_you_complete_your_studies
    application_choices.map do |application_choice|
      explanation = I18n.t(
        "candidate_interface.visa_explanation_component.#{application_choice.visa_explanation}",
      )

      if application_choice.visa_explanation_other?
        tag.p("#{explanation}:", class: 'govuk-body govuk-!-margin-bottom-2') +
          tag.p(application_choice.visa_explanation_details, class: 'govuk-body govuk-!-padding-left-3')
      else
        explanation
      end
    end
  end

private

  def application_choices
    @application_choices ||= application_form
                               .application_choices
                               .where.not(sent_to_provider_at: nil)
                               .where.not(visa_explanation: nil)
                               .in_order_of(:visa_explanation, ApplicationChoice.visa_explanations.values)
  end
end
