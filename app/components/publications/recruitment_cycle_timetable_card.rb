module Publications
  class RecruitmentCycleTimetableCard < ApplicationComponent
    def initialize(timetable)
      @timetable = timetable
    end

    attr_reader :timetable

    def title_text
      current_year = RecruitmentCycleTimetable.current_year
      additional_text = if timetable.recruitment_cycle_year == current_year
                          t('.current_year')
                        elsif timetable.recruitment_cycle_year > current_year + 1
                          t('.proposed_timetable')
                        elsif timetable.recruitment_cycle_year == current_year + 1
                          t('.next_year')
                        elsif timetable.recruitment_cycle_year == current_year - 1
                          t('.previous_year')
                        end
      "#{additional_text} #{timetable.cycle_range_name}".strip
    end
  end
end
