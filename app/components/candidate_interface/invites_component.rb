module CandidateInterface
  class InvitesComponent < ViewComponent::Base
    attr_reader :invites

    def initialize(invites:)
      @invites = invites
    end

    def application_choice_link(invite)
      application_choice = invite.application_choice

      if application_choice.offer?
        candidate_interface_offer_path(application_choice, return_to: 'invites')
      else
        candidate_interface_course_choices_course_review_path(application_choice, return_to: 'invites')
      end
    end

    def status_tag(invite)
      if invite.applied? && invite.application_choice.present?
        govuk_tag text: invite.candidate_decision.capitalize, colour: 'green'
      elsif invite.declined?
        govuk_tag text: invite.candidate_decision.capitalize, colour: 'red'
      elsif invite.course_closed?
        govuk_tag text: t('.closed'), colour: 'grey'
      end
    end

    def action_link(invite)
      if invite.applied? && invite.application_choice.present?
        govuk_link_to t('.view_application'), application_choice_link(invite)
      elsif invite.declined? || !invite.course_open?
        govuk_link_to t('.view_course'), invite.course.find_url
      else
        govuk_link_to t('.view_invite'), edit_candidate_interface_invite_path(invite)
      end
    end
  end
end
