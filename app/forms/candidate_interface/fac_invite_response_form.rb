module CandidateInterface
  class FacInviteResponseForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Rails.application.routes.url_helpers

    attribute :invite
    attribute :apply_for_this_course, :string

    validates :apply_for_this_course, presence: true

    def save
      return false unless valid?

      true
    end

    def path_to_redirect
      draft_application_choice = invite.application_form.application_choices.unsubmitted
        .joins(:course_option)
        .find_by(course_option: { course_id: invite.course_id })

      if accepted_invite? && draft_application_choice.present?
        CandidateInterface::InviteApplication.accept_and_link_to_choice!(
          application_choice: draft_application_choice,
          invite:,
        )

        candidate_interface_course_choices_course_review_path(draft_application_choice, return_to: 'invite')
      elsif accepted_invite?
        candidate_interface_course_choices_course_confirm_selection_path(invite.course)
      else
        new_candidate_interface_invite_decline_reason_path(invite)
      end
    end

  private

    def accepted_invite?
      apply_for_this_course.to_s.strip.downcase == 'yes'
    end
  end
end
