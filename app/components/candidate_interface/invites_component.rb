module CandidateInterface
  class InvitesComponent < ViewComponent::Base
    attr_reader :application_form, :invites

    def initialize(application_form:, invites:)
      @application_form = application_form
      @invites = invites.select { |invite| invite.course.open? }
    end

    def application_choice_link(invite)
      application_choice = invite.application_choice

      if application_choice.nil?
        # I have added this to reset the invite status to not_responded if the draft was deleted following accepting the invite
        invite.update!(
          candidate_decision: 'not_responded',
          application_choice_id: nil,
        )
        return nil
      end

      if application_choice.offer?
        candidate_interface_offer_path(application_choice, return_to: 'invites')
      else
        candidate_interface_course_choices_course_review_path(application_choice, return_to: 'invites')
      end
    end
  end
end
