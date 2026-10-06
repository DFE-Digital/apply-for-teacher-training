module Publications
  class RecruitmentCycleTimetableCard < ApplicationComponent
    def initialize(timetable, logged_in: false)
      @timetable = timetable
      @logged_in = logged_in
    end

    attr_reader :timetable

    def change_link?
      @logged_in && timetable.editable_in_production?
    end

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
