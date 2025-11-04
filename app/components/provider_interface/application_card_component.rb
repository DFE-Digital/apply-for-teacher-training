module ProviderInterface
  class ApplicationCardComponent < ViewComponent::Base
    include ViewHelper
    include TaskViewHelper

    attr_accessor :accredited_provider, :application_choice, :application_choice_path,
                  :candidate_name, :course_name_and_code, :course_provider_name, :changed_at,
                  :site_name, :course_study_mode

    delegate :current_course, to: :application_choice
    delegate :course_type, :undergraduate?, to: :current_course

    def initialize(application_choice:)
      @accredited_provider = application_choice.current_accredited_provider
      @application_choice = application_choice
      @candidate_name = application_choice.application_form.full_name
      @course_name_and_code = application_choice.current_course.name_and_code
      @course_study_mode = application_choice.current_course_option.study_mode.humanize.downcase
      @course_provider_name = application_choice.current_provider.name
      @changed_at = application_choice.updated_at.to_fs(:govuk_date_and_time)
      @site_name = application_choice.current_site.name
    end

    def relative_date_text
      if application_choice.offer?
        days = application_choice.days_since_offered
        "Offer made #{days_since(days)}"
      else
        days = application_choice.days_since_sent_to_provider
        "Received #{days_since(days)}"
      end
    end

    def recruitment_cycle_text
      if application_choice.recruitment_cycle == current_timetable.recruitment_cycle_year
        "Current cycle (#{current_timetable.cycle_range_name})"
      elsif application_choice.recruitment_cycle == previous_timetable.recruitment_cycle_year
        "Previous cycle (#{previous_timetable.cycle_range_name})"
      else
        timetable = application_choice.current_course.recruitment_cycle_timetable
        "Recruitment cycle:\n#{timetable.cycle_range_name}"
      end
    end

    def current_timetable
      @current_timetable ||= RecruitmentCycleTimetable.current_timetable
    end

    def previous_timetable
      @previous_timetable ||= RecruitmentCycleTimetable.previous_timetable
    end
  end
end
