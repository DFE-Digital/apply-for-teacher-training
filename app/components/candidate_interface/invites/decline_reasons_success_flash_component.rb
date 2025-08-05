# frozen_string_literal: true

class CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent < ViewComponent::Base
  def initialize(invite:)
    @invite = invite
  end

  def call
    tag.div do
      tag.p do
        concat 'If you have changed your mind you can still '
        concat govuk_link_to('apply to this course', candidate_interface_course_choices_course_confirm_selection_path(course), class: 'govuk-notification-banner__link')
      end
    end
  end

private

  attr_reader :invite

  delegate :candidate, :course, to: :invite
  delegate :decline_reasons_include_only_salaried?, to: :invite, prefix: true
end
