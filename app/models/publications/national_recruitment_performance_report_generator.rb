module Publications
  class NationalRecruitmentPerformanceReportGenerator
    attr_reader :client,
                :generation_date,
                :publication_date,
                :report_expected_time,
                :cycle_week,
                :recruitment_cycle_year

    def initialize(cycle_week:, generation_date: Time.zone.now, publication_date: nil, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
      @cycle_week = cycle_week
      @generation_date = generation_date
      @publication_date = publication_date.presence || @generation_date
      @recruitment_cycle_year = recruitment_cycle_year
      @report_expected_time = 1.week.until(@generation_date).end_of_week
      @client = DfE::Bigquery::ApplicationMetricsByProvider.new(cycle_week:)
    end

    def call
      Publications::NationalRecruitmentPerformanceReport.create!(
        statistics: data,
        cycle_week:,
        publication_date:,
        generation_date:,
        recruitment_cycle_year:,
      )
    end

    def data
      client.national_data.map(&:attributes)
    end
  end
end
