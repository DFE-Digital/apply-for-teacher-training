module CandidateInterface
  class CarryOverMidCycleComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:)
      @application_form = application_form
    end

    def application_form_academic_cycle
      @application_form.recruitment_cycle_timetable.academic_year_range_name
    end

    def next_academic_cycle
      next_timetable.academic_year_range_name
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
