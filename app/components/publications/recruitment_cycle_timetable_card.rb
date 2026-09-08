module Publications
  class RecruitmentCycleTimetableCard < ApplicationComponent
    def initialize(timetable)
      @timetable = timetable
    end

    attr_reader :timetable

    delegate :recruitment_cycle_year, :cycle_range_name, to: :timetable

    def title_text
      current_year = RecruitmentCycleTimetable.current_year
      additional_text = if recruitment_cycle_year == current_year
                          t('.current_year')
                        elsif recruitment_cycle_year > current_year + 1
                          t('.proposed_timetable')
                        elsif recruitment_cycle_year == current_year + 1
                          t('.next_year')
                        elsif recruitment_cycle_year == current_year - 1
                          t('.previous_year')
                        end
      govuk_link_to(
        "#{additional_text} #{cycle_range_name}".strip,
        publications_recruitment_cycle_timetable_path(recruitment_cycle_year:)
      )
    end
  end
end
