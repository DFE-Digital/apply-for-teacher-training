module CandidateInterface
  class InvitesComponent < ViewComponent::Base
    attr_reader :invites

    def initialize(invites:)
      @invites = invites
    end

    def application_choice_link(invite)
      if invite.application_choice.offer?
        candidate_interface_offer_path(invite.application_choice, return_to: 'invites')
      else
        candidate_interface_course_choices_course_review_path(invite.application_choice, return_to: 'invites')
      end
    end

    def status_tag(invite)
      if invite.accepted? && invite.application_choice.present?
        govuk_tag text: invite.candidate_decision.capitalize, colour: 'green'
      elsif invite.declined?
        govuk_tag text: invite.candidate_decision.capitalize, colour: 'red'
      elsif invite.course_closed?
        govuk_tag text: t('.closed'), colour: 'grey'
      end
    end

    def hint_text
      if invites.blank?
        t('.no_invites')
      else
        t('.previous_invitations_hint')
      end
    end

    def action_link(invite)
      if invite.accepted? && invite.application_choice.present?
        govuk_link_to t('.view_application'), application_choice_link(invite)
      else
        govuk_link_to t('.view_course'), invite.course.find_url
      end
    end
  end
end
