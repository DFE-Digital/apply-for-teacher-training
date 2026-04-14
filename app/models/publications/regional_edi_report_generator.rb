module Publications
  class RegionalEdiReportGenerator
    attr_reader :client,
                :generation_date,
                :publication_date,
                :cycle_week,
                :region,
                :recruitment_cycle_year

    def initialize(
      cycle_week:,
      region:,
      generation_date: Time.zone.now,
      publication_date: nil, recruitment_cycle_year: RecruitmentCycleTimetable.current_year
    )
      @cycle_week = cycle_week
      @region = region
      @generation_date = generation_date
      @publication_date = publication_date.presence || @generation_date
      @recruitment_cycle_year = recruitment_cycle_year
      @client = if region == ReportSharedEnums.all_of_england_value
                  DfE::Bigquery::NationalEdiMetrics.new(
                    cycle_week:,
                    recruitment_cycle_year:,
                  )
                else
                  DfE::Bigquery::RegionalEdiMetrics.new(
                    cycle_week:,
                    region:,
                    recruitment_cycle_year:,
                  )
                end
    end

    def call
      if data.empty?
        Rails.logger.info('No recruitment performance data was received.')
        return
      end

      Publications::ProviderEdiReport.categories.each_value do |category|
        next if Publications::RegionalEdiReport.exists?(
          cycle_week:,
          recruitment_cycle_year:,
          region:,
          category:,
        )

        filter_category = category.downcase == 'disability' ? 'HESA disability' : category
        filter = @client.is_a?(DfE::Bigquery::NationalEdiMetrics) ? 'nonprovider_filter_category' : 'nonregion_filter_category'

        category_data = data.select do |datum|
          datum[filter] == filter_category
        end
        next if category_data.empty?

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
    end

    def data
      client.data.map(&:attributes)
    end
  end
end
