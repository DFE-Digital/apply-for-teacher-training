class CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent < ViewComponent::Base
  def initialize(invite:)
    @invite = invite
  end

  def call
    if change_preferences_text_component
      render change_preferences_text_component
    else
      tag.div do
        tag.p do
          concat 'If you have changed your mind you can still '
          concat govuk_link_to('apply to this course', candidate_interface_course_choices_course_confirm_selection_path(course), class: 'govuk-notification-banner__link')
        end
      end
    end
  end

  def change_preferences_text_component
    if invite_decline_reasons_include_only_salaried? && invite_decline_reasons_include_location_not_convenient?
      CandidateInterface::Invites::DeclineReasonsSuccessFlash::UpdateLocationAndFundingPreferencesComponent.new(invite: invite)
    elsif invite_decline_reasons_include_only_salaried?
      CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeFundingPreferencesComponent.new(invite: invite)
    elsif invite_decline_reasons_include_location_not_convenient?
      CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeLocationPreferencesComponent.new(invite: invite)
    end
  end

  def candidate_interface_candidate_preferences_review_path
    return new_candidate_interface_pool_opt_in_path unless candidate.published_preference

    return candidate_interface_draft_preference_publish_preferences_path(candidate.published_preference) if candidate.published_preference_opt_in?

    edit_candidate_interface_pool_opt_in_path(candidate.published_preference)
  end

private

  attr_reader :invite

  delegate :candidate, :course, to: :invite
  delegate :decline_reasons_include_only_salaried?,
           :decline_reasons_include_location_not_convenient?,
           :decline_reasons_include_no_longer_interested?,
           to: :invite, prefix: true
end
