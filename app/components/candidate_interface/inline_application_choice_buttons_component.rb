class CandidateInterface::InlineApplicationChoiceButtonsComponent < ApplicationComponent
  include ViewHelper

  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  delegate :can_add_more_choices?, :application_choices, to: :application_form

  def application_choices_count
    return 2 if application_form.submitted?

    application_choices.count
  end

  def application_choice_link
    return candidate_interface_application_choices_path if application_form.submitted?

    if application_choices.one?
      application_choice = application_choices.last
      if application_choice.offer?
        candidate_interface_offer_path(application_choice.id)
      else
        candidate_interface_course_choices_course_review_path(application_choice.id)
      end
    else
      candidate_interface_application_choices_path
    end
  end
end
