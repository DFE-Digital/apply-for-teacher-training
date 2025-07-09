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
end
