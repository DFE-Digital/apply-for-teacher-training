module DataMigrations
  class MonthlyReportsBackfill
    TIMESTAMP = 20220711115142
    MANUAL_RUN = false

    GENERATION_DATES = {
      '2021-10' => Date.new(RecruitmentCycle.previous_year, 10, 18),
      '2021-11' => Date.new(RecruitmentCycle.previous_year, 11, 22),
      '2021-12' => Date.new(RecruitmentCycle.previous_year, 12, 20),
      '2022-01' => Date.new(RecruitmentCycle.current_year, 1, 17),
      '2022-02' => Date.new(RecruitmentCycle.current_year, 2, 21),
      '2022-03' => Date.new(RecruitmentCycle.current_year, 3, 21),
      '2022-04' => Date.new(RecruitmentCycle.current_year, 4, 18),
      '2022-05' => Date.new(RecruitmentCycle.current_year, 5, 16),
      '2022-06' => Date.new(RecruitmentCycle.current_year, 6, 20),
    }.freeze

    # The date the report will be pubished a week after the generation date
    PUBLISHING_DATES = {
      '2021-10' => Date.new(RecruitmentCycle.previous_year, 10, 25),
      '2021-11' => Date.new(RecruitmentCycle.previous_year, 11, 29),
      '2021-12' => Date.new(RecruitmentCycle.previous_year, 12, 27),
      '2022-01' => Date.new(RecruitmentCycle.current_year, 1, 24),
      '2022-02' => Date.new(RecruitmentCycle.current_year, 2, 28),
      '2022-03' => Date.new(RecruitmentCycle.current_year, 3, 28),
      '2022-04' => Date.new(RecruitmentCycle.current_year, 4, 25),
      '2022-05' => Date.new(RecruitmentCycle.current_year, 5, 23),
      '2022-06' => Date.new(RecruitmentCycle.current_year, 6, 27),
    }.freeze

    def change
      GENERATION_DATES.each do |month, generation_date|
        Publications::MonthlyStatistics::MonthlyStatisticsReport.where(month: month).update_all(
          generation_date: generation_date,
          publication_date: PUBLISHING_DATES[month],
        )
      end
    end
  end
end
