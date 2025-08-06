module CandidateInterface
  class InviteApplication
    attr_reader :application_form, :application_choice

    def initialize(application_choice:, application_form: nil, invite: nil)
      @application_form = application_form
      @application_choice = application_choice
      @invite = invite
    end

    def self.accepted!(application_form:, application_choice:)
      new(application_form:, application_choice:).accepted!
    end

    def accepted!
      clean_up_disconnected_invites

      invite = application_form.published_invites.find_by(
        course_id: application_choice.current_course.id,
        application_choice_id: nil,
      )

      if invite.present? && application_choice.persisted?
        invite.update!(
          application_choice_id: application_choice.id,
          candidate_decision: 'accepted',
        )
      end
    end

    def self.accept_and_link_to_choice!(application_choice:, invite:)
      new(application_choice:, invite:).accept_and_link_to_choice!
    end

    def accept_and_link_to_choice!
      @invite.update!(
        application_choice:,
        candidate_decision: 'accepted',
      )
    end

    def self.unlink_invites_from_choice(application_choice:)
      new(application_choice:).unlink_invites_from_choice
    end

    def unlink_invites_from_choice
      application_choice.published_invites.update_all(
        application_choice_id: nil,
        candidate_decision: 'not_responded',
      )
    end

  private

    def clean_up_disconnected_invites
      # When a candidate creates a draft choice for invited course and changes course to a non invited course
      # We then need to remove the link between the choice and the invite
      if application_choice.current_course == application_choice.original_course
        application_choice.published_invites.where.not(
          course_id: application_choice.current_course.id,
        ).update_all(
          application_choice_id: nil,
          candidate_decision: 'not_responded',
        )
      end
    end
  end
end
