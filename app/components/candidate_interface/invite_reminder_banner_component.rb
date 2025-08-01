class CandidateInterface::InviteReminderBannerComponent < ViewComponent::Base
  attr_reader :invites

  def initialize(invites:)
    @invites = invites
  end

  def render?
    invites.not_responded.count >= 2
  end
end
