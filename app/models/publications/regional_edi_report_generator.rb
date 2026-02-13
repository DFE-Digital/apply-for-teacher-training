module Publications
  class RegionalEdiReportGenerator
    attr_reader :client,
                :generation_date,
                :publication_date,
                :cycle_week,
                :region,
                :category,
                :recruitment_cycle_year

    def initialize(
      cycle_week:,
      region:,
      category:,
      generation_date: Time.zone.now,
      publication_date: nil, recruitment_cycle_year: RecruitmentCycleTimetable.current_year
    )
      @cycle_week = cycle_week
      @region = region
      @category = category
      @generation_date = generation_date
      @publication_date = publication_date.presence || @generation_date
      @recruitment_cycle_year = recruitment_cycle_year
      @client = if region == ReportSharedEnums.all_of_england_value
                  DfE::Bigquery::NationalEdiMetrics.new(
                    cycle_week:,
                    category:,
                  )
                else
                  DfE::Bigquery::RegionalEdiMetrics.new(
                    cycle_week:,
                    region:,
                    category:,
                  )
                end
    end

    def call
      Publications::RegionalEdiReport.create!(
        statistics: data,
        region:,
        category:,
        cycle_week:,
        publication_date:,
        generation_date:,
        recruitment_cycle_year:,
      )
    end

    def data
      client.data.map(&:attributes)
    end
  end
end
