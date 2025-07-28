module CandidateInterface
  class InviteApplication
    attr_reader :application_form, :application_choice

    def initialize(application_form:, application_choice:)
      @application_form = application_form
      @application_choice = application_choice
    end

    def self.applied!(application_form:, application_choice:)
      new(application_form:, application_choice:).applied!
    end

    def applied!
      clean_up_orphan_invites

      invite = application_form.published_invites.find_by(
        course_id: application_choice.current_course.id,
        application_choice_id: nil,
      )

      if invite.present? && application_choice.persisted?
        invite.update!(
          application_choice_id: application_choice.id,
          candidate_decision: 'applied',
        )
      end
    end

  private

    def clean_up_orphan_invites
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
