module ProviderInterface
  class RegionalReportForm
    Region = Data.define(:label, :value)
    include ActiveModel::Model

    attr_accessor :region, :provider_id, :provider_user_id

    validates :region, presence: true

    def options
      result = Publications::RegionalRecruitmentPerformanceReport.regions.each.map do |key, value|
        Region.new(value, key)
      end
      result.prepend(
        Region.new(
          Publications::RegionalRecruitmentPerformanceReport.all_of_england_value,
          Publications::RegionalRecruitmentPerformanceReport.all_of_england_key,
        ),
      )
      result
    end

    def self.initialize_from_report_filter(provider_id:, provider_user_id:)
      region = RegionalReportFilter.find_by(
        provider_id:,
        provider_user_id:,
      )&.region

      new({ region:, provider_id:, provider_user_id: })
    end

    def save
      return if invalid?

      regional_filter = RegionalReportFilter.find_or_create_by(
        region:,
        provider_id:,
        provider_user_id:,
      )
      RegionalReportFilter.where(
        provider_id:,
        provider_user_id:,
      ).where.not(id: regional_filter.id)&.delete_all

      regional_filter
    end
  end
end
