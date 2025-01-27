module DataMigrations
  class AddAllRecruitmentCycleTimetablesToDatabase
    TIMESTAMP = 20250127165056
    MANUAL_RUN = false

    def change
      CYCLE_DATES.each do |recruitment_cycle_year, attributes|
        dates = attributes.filter do |date|
          %i[
            apply_1_deadline
            apply_2_deadline
            show_deadline_banner
            show_summer_recruitment_banner
          ].exclude? date
        end

        dates[:christmas_holiday] = dates.dig(:holidays, :christmas)
        dates[:easter_holiday] = dates.dig(:holidays, :easter)
        dates[:decline_by_default] = dates[:find_closes] - 1.day
        dates = dates.filter { |date| date != :holidays }

        RealCycleTimetable.create(recruitment_cycle_year:, **dates)
      end
    end
  end
end
