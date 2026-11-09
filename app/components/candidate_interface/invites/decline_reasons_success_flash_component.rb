class CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent < ApplicationComponent
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
    if invite_decline_reasons_include_no_longer_interested?
      CandidateInterface::Invites::DeclineReasonsSuccessFlash::NoLongerInterestedComponent.new(invite: invite)
    elsif invite_decline_reasons_include_only_salaried? && invite_decline_reasons_include_location_not_convenient?
      CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeLocationAndFundingPreferencesComponent.new(invite: invite)
    elsif invite_decline_reasons_include_only_salaried?
      CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeFundingPreferencesComponent.new(invite: invite)
    elsif invite_decline_reasons_include_location_not_convenient?
      CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeLocationPreferencesComponent.new(invite: invite)
    end
  end

  def candidate_interface_candidate_preferences_review_path
    return candidate_interface_new_preferences_path(step: :opt_in) unless application_form.published_preference

    return candidate_interface_edit_preferences_path(step: :publish) if application_form.published_preference_opt_in?

    candidate_interface_edit_preferences_path(step: :opt_in)
  end

private

  attr_reader :invite

  delegate :candidate, :course, :application_form, to: :invite
  delegate :decline_reasons_include_only_salaried?,
           :decline_reasons_include_location_not_convenient?,
           :decline_reasons_include_no_longer_interested?,
           to: :invite, prefix: true
end
