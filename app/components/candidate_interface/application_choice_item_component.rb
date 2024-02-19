class CandidateInterface::ApplicationChoiceItemComponent < ViewComponent::Base
  def initialize(application_choice:)
    @application_choice = application_choice
  end
  attr_reader :application_choice
  delegate :status, to: :application_choice

  def provider_name
    application_choice.current_course.provider.name
  end

  def application_id
    application_choice.id
  end

  def course_name
    application_choice.current_course.name_and_code
  end

  def study_mode
    application_choice.current_course_option.study_mode.humanize
  end

  def site_name
    application_choice.site.name
  end

  def view_application_path
    if application_choice.offer?
      candidate_interface_offer_path(application_choice.id)
    else
      candidate_interface_continuous_applications_course_review_path(application_choice.id)
    end
  end
end
