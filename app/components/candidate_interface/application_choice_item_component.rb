class CandidateInterface::ApplicationChoiceItemComponent < ViewComponent::Base
  def initialize(application_choice:)
    @application_choice = application_choice
  end
  attr_reader :application_choice
  delegate :status, :school_placement_auto_selected, to: :application_choice
  delegate :decline_by_default_at, to: :timetable

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

  def course_option_summary
    if school_placement_auto_selected
      "#{course_name} - #{study_mode}"
    else
      "#{course_name} - #{study_mode} at #{site_name}"
    end
  end

  def view_application_path
    if application_choice.offer?
      candidate_interface_offer_path(application_choice.id)
    else
      candidate_interface_course_choices_course_review_path(application_choice.id)
    end
  end

  def show_decline_by_default_text?
    application_choice.offer? && Time.zone.now.between?(timetable.apply_deadline_at, decline_by_default_at)
  end

private

  def timetable
    @timetable ||= RecruitmentCycleTimetable.current_timetable
  end
end
