module Publications
  class RecruitmentCycleTimetableCard < ApplicationComponent
    def initialize(timetable, show_link: false)
      @timetable = timetable
      @show_link = show_link
    end

    attr_reader :timetable, :show_link

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

      if show_link
        govuk_link_to(
          "#{additional_text} #{cycle_range_name}".strip,
          publications_recruitment_cycle_timetable_path(recruitment_cycle_year:)
        )
      else
        "#{additional_text} #{cycle_range_name}".strip
      end
    end
  end
end
