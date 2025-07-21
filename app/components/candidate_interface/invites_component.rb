module CandidateInterface
  class InvitesComponent < ViewComponent::Base
    attr_reader :application_form, :invites

    def initialize(application_form:, invites:)
      @application_form = application_form
      @invites = invites
    end

    def application_choice_link(invite)
      if invite.application_choice.offer?
        candidate_interface_offer_path(invite.application_choice, return_to: 'invites')
      else
        candidate_interface_course_choices_course_review_path(invite.application_choice, return_to: 'invites')
      end
    end
  end
end
