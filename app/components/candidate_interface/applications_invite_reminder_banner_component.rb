class CandidateInterface::ApplicationsInviteReminderBannerComponent < ApplicationComponent
  attr_reader :invites

  def initialize(invites:)
    @invites = invites
  end

  def render?
    invites.not_responded.any?
  end

  def banner_text
    if invites.not_responded.many?
      t('.many_invites_content')
    else
      t('.one_invite_content')
    end
  end

  def list_type
    invites.many? ? :bullet : nil
  end
end
