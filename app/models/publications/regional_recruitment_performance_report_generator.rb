module Publications
  class RegionalRecruitmentPerformanceReportGenerator
    attr_reader :client,
                :generation_date,
                :publication_date,
                :cycle_week,
                :region,
                :recruitment_cycle_year

    def initialize(cycle_week:, region:, generation_date: Time.zone.now, publication_date: nil, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
      @cycle_week = cycle_week
      @region = region
      @generation_date = generation_date
      @publication_date = publication_date.presence || @generation_date
      @recruitment_cycle_year = recruitment_cycle_year
      @client = DfE::Bigquery::ApplicationMetricsByRegion.new(cycle_week:, region:)
    end

    def call
      Publications::RegionalRecruitmentPerformanceReport.create!(
        statistics: data,
        region:,
        cycle_week:,
        publication_date:,
        generation_date:,
        recruitment_cycle_year:,
      )
    end

    def data
      client.regional_data.map(&:attributes)
    end
  end
end
