module CandidateInterface
  class NotRespondedInvitesComponent < ViewComponent::Base
    attr_reader :invites

    def initialize(invites:)
      @invites = invites
    end

    def hint_text
      if invites.blank?
        t('.no_invites')
      else
        t('.awaiting_response_hint')
      end
    end
  end
end
