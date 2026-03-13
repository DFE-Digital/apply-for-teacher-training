module CandidateInterface
  class NotRespondedInvitesComponent < ApplicationComponent
    attr_reader :invites

    def initialize(invites:)
      @invites = invites
    end

    def hint_text
      if invites.blank?
        t('candidate_interface.not_responded_invites_component.no_invites')
      else
        t('candidate_interface.not_responded_invites_component.awaiting_response_hint')
      end
    end
  end
end
