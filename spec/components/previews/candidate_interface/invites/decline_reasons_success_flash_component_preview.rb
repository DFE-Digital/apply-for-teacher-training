class CandidateInterface::Invites::DeclineReasonsSuccessFlashComponentPreview < ViewComponent::Preview
  def default
    invite = FactoryBot.build_stubbed(:pool_invite)

    render CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent.new(invite:)
  end

  def no_longer_interested
    invite = FactoryBot.build_stubbed(:pool_invite)

    render CandidateInterface::Invites::DeclineReasonsSuccessFlash::NoLongerInterestedComponent.new(invite:)
  end

  def change_location_and_funding_preferences
    preference = FactoryBot.build_stubbed(:candidate_preference, pool_status: :opt_in, funding_type: 'salary')
    application_form = FactoryBot.build_stubbed(:application_form, published_preference: preference)
    invite = FactoryBot.build_stubbed(:pool_invite, application_form: application_form)

    render CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeLocationAndFundingPreferencesComponent.new(invite:)
  end

  def change_funding_preferences
    application_form = FactoryBot.build_stubbed(:application_form, published_preference: FactoryBot.build_stubbed(:candidate_preference, pool_status: :opt_in, funding_type: 'salary'))
    invite = FactoryBot.build_stubbed(:pool_invite, application_form: application_form)

    render CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeFundingPreferencesComponent.new(invite:)
  end

  def change_location_preferences
    invite = FactoryBot.build_stubbed(:pool_invite)

    render CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeLocationPreferencesComponent.new(invite:)
  end
end
