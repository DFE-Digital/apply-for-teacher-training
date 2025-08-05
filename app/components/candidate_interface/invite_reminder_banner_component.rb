class CandidateInterface::InviteReminderBannerComponent < ViewComponent::Base
  attr_reader :invites

  def initialize(invites:)
    @invites = invites
  end

  def render?
    invites.not_responded.count >= Pool::Invite::NUMBER_OF_INVITES_TO_REMOVE_FROM_POOL
  end
end
