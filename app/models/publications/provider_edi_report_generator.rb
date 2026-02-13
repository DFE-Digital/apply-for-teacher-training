module Publications
  class ProviderEdiReportGenerator
    attr_reader :client,
                :provider_id,
                :generation_date,
                :publication_date,
                :cycle_week,
                :category,
                :recruitment_cycle_year

    def initialize(
      provider_id:,
      cycle_week:,
      category:,
      generation_date: Time.zone.today,
      publication_date: nil,
      recruitment_cycle_year: RecruitmentCycleTimetable.current_year
    )
      @provider_id = provider_id
      @generation_date = generation_date
      @publication_date = publication_date.presence || @generation_date
      @recruitment_cycle_year = recruitment_cycle_year
      @cycle_week = cycle_week
      @category = category

      @client = DfE::Bigquery::NationalEdiMetrics.new(
        cycle_week:,
        category:,
        provider_id:,
      )
    end

    def call
      if data.empty?
        Rails.logger.info("No recruitment performance data was received for #{provider_id}")
        return
      end

      Publications::ProviderEdiReport.create!(
        provider_id:,
        statistics: data,
        cycle_week:,
        category:,
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
