class CandidateInterface::ApplicationsInviteReminderBannerComponent < ViewComponent::Base
  attr_reader :invites

  def initialize(invites:)
    @invites = invites
  end

  def render?
    invites.not_responded.any?
  end

  def banner_text
    if invites.not_responded.many?
      'Respond to these invitations. You will not receive new invitations until you respond.'
    else
      'Respond to this invitation to continue receiving invitations to apply to courses.'
    end
  end

  def list_type
    invites.many? ? :bullet : nil
  end
end
