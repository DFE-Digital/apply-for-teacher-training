# frozen_string_literal: true

class CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent < ViewComponent::Base
  def initialize(invite:)
    @invite = invite
  end

  def call
    if change_preferences_text
      render change_preferences_text
    else
      tag.div do
        tag.p do
          concat 'If you have changed your mind you can still '
          concat govuk_link_to('apply to this course', candidate_interface_course_choices_course_confirm_selection_path(course), class: 'govuk-notification-banner__link')
        end
      end
    end
  end

  def change_preferences_text
    if invite_decline_reasons_include_no_longer_interested?
      NoLongerInterestedComponent.new(invite: invite)
    elsif invite_decline_reasons_include_only_salaried? && invite_decline_reasons_include_location_not_convenient?
      UpdateLocationAndFundingPreferencesComponent.new(invite: invite)
    elsif invite_decline_reasons_include_only_salaried?
      ChangeFundingPreferencesComponent.new(invite: invite)
    elsif invite_decline_reasons_include_location_not_convenient?
      ChangeLocationPreferencesComponent.new(invite: invite)
    end
  end

private

  attr_reader :invite

  delegate :candidate, :course, to: :invite
  delegate :decline_reasons_include_only_salaried?,
           :decline_reasons_include_location_not_convenient?,
           :decline_reasons_include_no_longer_interested?,
           to: :invite, prefix: true

  class NoLongerInterestedComponent < CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent
    def call
      tag.p('You will no longer receive invitations to apply for courses.')
    end
  end

  class UpdateLocationAndFundingPreferencesComponent < CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent
    def call
      tag.div do
        concat(
          tag.p do
            concat govuk_link_to('Update your location and funding preferences', candidate_interface_candidate_preferences_path(candidate), class: 'govuk-notification-banner__link')
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

  class ChangeFundingPreferencesComponent < CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent
    def call
      tag.div do
        concat(
          tag.p do
            concat govuk_link_to('Change your funding preferences', candidate_interface_candidate_preferences_path(candidate), class: 'govuk-notification-banner__link')
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

  class ChangeLocationPreferencesComponent < CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent
    def call
      tag.div do
        concat(
          tag.p do
            concat tag.a('Change your location preferences', href: candidate_interface_candidate_preferences_path(candidate), class: 'govuk-notification-banner__link')
            concat ' to receive invitations to more relevant courses'
          end,
        )

        concat(
          tag.p do
            concat 'If you have changed your mind you can still '
            concat tag.a('apply to this course', href: candidate_interface_course_choices_course_confirm_selection_path(course), class: 'govuk-notification-banner__link')
          end,
        )
      end
    end
  end
end
