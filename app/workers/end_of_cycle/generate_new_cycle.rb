module EndOfCycle
  class GenerateNewCycle < ApplicationJob
    def perform
      timetable = RecruitmentCycleTimetable.find_by(
        recruitment_cycle_year: RecruitmentCycleTimetable.current_year + 3,
      )

      if timetable.nil? && Time.zone.now.month == 7
        SupportInterface::RecruitmentCycleTimetableGenerator.generate_next_year
      end
    end
  end
end
