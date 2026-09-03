class ProviderInterface::FindCandidates::RightToWorkComponentPreview < ViewComponent::Preview
  def candidate_requires_sponsorship
    application_form = FactoryBot.build(:application_form, right_to_work_or_study: 'no')

    render ProviderInterface::FindCandidates::RightToWorkComponent.new(application_form:)
  end

  def candidate_british_does_not_require_sponsorship
    application_form = FactoryBot.build(:application_form, right_to_work_or_study: nil, first_nationality: 'British')

    render ProviderInterface::FindCandidates::RightToWorkComponent.new(application_form:)
  end

  def candidate_has_visa_does_not_require_sponsorship
    application_form = FactoryBot.build(
      :application_form,
      right_to_work_or_study: 'yes',
      immigration_status: 'indefinite_leave_to_remain_in_the_uk',
    )

    render ProviderInterface::FindCandidates::RightToWorkComponent.new(application_form:)
  end

  def candidate_has_visa_expiry
    application_form = FactoryBot.build(
      :application_form,
      right_to_work_or_study: 'yes',
      immigration_status: 'indefinite_leave_to_remain_in_the_uk',
      visa_expired_at: '01/01/2028',
    )

    render ProviderInterface::FindCandidates::RightToWorkComponent.new(application_form:)
  end

  def candidate_has_visa_explanation
    application_form = FactoryBot.build(
      :application_form,
      right_to_work_or_study: 'yes',
      immigration_status: 'indefinite_leave_to_remain_in_the_uk',
      visa_expired_at: '01/01/2028',
    )

    render PreviewRightToWorkComponent.new(application_form:)
  end

  class PreviewRightToWorkComponent < ProviderInterface::FindCandidates::RightToWorkComponent
    def application_choices
      [
        FactoryBot.build(:application_choice, :awaiting_provider_decision, visa_explanation: 'expires_after_course'),
        FactoryBot.build(:application_choice, :awaiting_provider_decision, visa_explanation: 'other', visa_explanation_details: 'I have the right to work.'),
      ]
    end
  end
end
