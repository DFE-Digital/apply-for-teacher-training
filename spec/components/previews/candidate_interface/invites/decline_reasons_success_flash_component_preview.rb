# frozen_string_literal: true

class CandidateInterface::Invites::DeclineReasonsSuccessFlashComponentPreview < ViewComponent::Preview
  def default
    invite = FactoryBot.build_stubbed(:pool_invite)

    render(CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent.new(invite:))
  end

  def no_longer_interested
    invite = FactoryBot.build_stubbed(:pool_invite)

    render(CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent::NoLongerInterestedComponent.new(invite:))
  end

  def update_location_and_funding_preferences
    invite = FactoryBot.build_stubbed(:pool_invite)

    render(CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent::UpdateLocationAndFundingPreferencesComponent.new(invite:))
  end

  def change_funding_preferences
    invite = FactoryBot.build_stubbed(:pool_invite)

    render(CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent::ChangeFundingPreferencesComponent.new(invite:))
  end

  def change_location_preferences
    invite = FactoryBot.build_stubbed(:pool_invite)

    render(CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent::ChangeLocationPreferencesComponent.new(invite:))
  end
end
