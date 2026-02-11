module Shared
  class ProviderRegionalReportForm < SupportRegionalReportForm
    attr_accessor :region, :provider_id, :provider_user_id

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
