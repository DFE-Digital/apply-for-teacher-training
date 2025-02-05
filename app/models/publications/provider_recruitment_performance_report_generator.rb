module Publications
  class ProviderRecruitmentPerformanceReportGenerator
    attr_reader :client,
                :provider_id,
                :generation_date,
                :publication_date,
                :report_expected_time,
                :cycle_week,
                :recruitment_cycle_year

    def initialize(provider_id:, cycle_week:, generation_date: Time.zone.today, publication_date: nil, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
      @provider_id = provider_id
      @generation_date = generation_date
      @publication_date = publication_date.presence || @generation_date
      @report_expected_time = 1.week.until(@generation_date).end_of_week
      @recruitment_cycle_year = recruitment_cycle_year
      @cycle_week = cycle_week
      @client = DfE::Bigquery::ApplicationMetricsByProvider.new(cycle_week:, provider_id:)
    end

    def call
      if data.empty?
        Rails.logger.info("No recruitment performance data was received for #{provider_id}")
        return
      end

      Publications::ProviderRecruitmentPerformanceReport.create!(
        provider_id:,
        statistics: data,
        cycle_week:,
        publication_date:,
        generation_date:,
        recruitment_cycle_year:,
      )
    end

    def data
      @data ||= client.provider_data.map(&:attributes)
    end
  end
end
