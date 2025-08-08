# frozen_string_literal: true

class CandidateInterface::Invites::DeclineReasonsSuccessFlash::UpdateLocationAndFundingPreferencesComponent < CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent
  def call
    tag.div do
      concat(
        tag.p do
          concat govuk_link_to('Update your location and funding preferences', candidate_interface_candidate_preferences_review_path, class: 'govuk-notification-banner__link')
          concat ' to receive invitations to more relevant courses'
        end,
      )

      concat(
        tag.p do
          concat 'If you have changed your mind you can still '
          concat govuk_link_to('apply to this course', candidate_interface_course_choices_course_confirm_selection_path(course), class: 'govuk-notification-banner__link')
        end,
      )
    end
  end
end
