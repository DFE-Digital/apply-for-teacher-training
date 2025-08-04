module CandidateInterface
  class CarryOverInterstitialComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:)
      @application_form = application_form
    end

    def application_form_academic_cycle
      @application_form.recruitment_cycle_timetable.academic_year_range_name
    end

    def application_form_start_month_year
      @application_form.recruitment_cycle_timetable.apply_deadline_at.to_fs(:month_and_year)
    end

    def next_academic_cycle
      next_timetable.academic_year_range_name
    end

    def next_start_month
      next_timetable.apply_deadline_at.to_fs(:month_and_year)
    end

    def application_choices
      CandidateInterface::SortApplicationChoices.call(
        application_choices: @application_form.application_choices
                                              .includes(:course, :site, :provider, :current_course, :current_course_option, :interviews)
                                              .includes(offer: :conditions),
      )
    end

    def apply_reopens_date
      next_timetable.apply_opens_at
    end

  private

    def next_timetable
      @next_timetable ||= if RecruitmentCycleTimetable.current_timetable.after_apply_deadline?
                            RecruitmentCycleTimetable.next_timetable
                          else
                            RecruitmentCycleTimetable.current_timetable
                          end
    end
  end
end
