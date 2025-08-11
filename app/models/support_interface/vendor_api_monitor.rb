module SupportInterface
  class VendorAPIMonitor
    include ApplicationHelper

    def initialize(vendor: nil)
      @vendor = vendor
    end

    def all_providers
      Provider.joins(:vendor).includes([:vendor])
    end

    def target_providers
      @vendor.present? ? all_providers.where(vendor: @vendor) : all_providers
    end

    def connected
      target_providers.select(:id, :name).where.not(id: never_connected.select(:id))
    end

    def never_connected
      target_providers
        .joins("LEFT JOIN (#{VendorAPIRequest.select('provider_id, COUNT(vendor_api_requests.id) as count').group('provider_id').to_sql}) all_time_requests on all_time_requests.provider_id = providers.id")
        .includes(:vendor_api_tokens).where(all_time_requests: { count: nil })
    end

    def no_sync_in_24h
      connected
        .select('last_syncs.last_sync as last_sync, vendor_id')
        .joins("LEFT JOIN (#{VendorAPIRequest.successful.syncs.select('provider_id, MAX(vendor_api_requests.created_at) as last_sync').group('provider_id').to_sql}) last_syncs on last_syncs.provider_id = providers.id")
        .where("last_sync < ('#{pg_now}'::TIMESTAMPTZ - interval '24 hours') OR last_sync IS NULL").order(last_sync: :desc)
    end

    def no_sync_in_7d
      connected
        .select('last_syncs.last_sync as last_sync, vendor_id')
        .joins("LEFT JOIN (#{VendorAPIRequest.successful.syncs.select('provider_id, MAX(vendor_api_requests.created_at) as last_sync').group('provider_id').to_sql}) last_syncs on last_syncs.provider_id = providers.id")
        .where("last_sync < ('#{pg_now}'::TIMESTAMPTZ - interval '7 days') OR last_sync IS NULL").order(last_sync: :desc)
    end

    def no_decisions_in_7d
      connected
        .select('last_decisions.last_decision as last_decision, vendor_id')
        .joins("LEFT JOIN (#{VendorAPIRequest.successful.decisions.select('provider_id, MAX(vendor_api_requests.created_at) as last_decision').group('provider_id').to_sql}) last_decisions on last_decisions.provider_id = providers.id")
      .where("last_decision < ('#{pg_now}'::TIMESTAMPTZ - interval '7 days') OR last_decision IS NULL").order(last_decision: :desc)
    end

    def providers_with_errors
      connected
        .select('errors.count as error_count,
          requests.count as request_count,
          (CAST(errors.count AS FLOAT)/requests.count) * 100 as error_rate,
          vendor_id')
        .joins("LEFT JOIN (#{VendorAPIRequest.errors.select('provider_id, COUNT(vendor_api_requests.id) as count').where("vendor_api_requests.created_at > ('#{pg_now}'::TIMESTAMPTZ - interval '7 days')").group('provider_id').to_sql}) errors on errors.provider_id = providers.id")
        .joins("LEFT JOIN (#{VendorAPIRequest.select('provider_id, COUNT(vendor_api_requests.id) as count').where("vendor_api_requests.created_at > ('#{pg_now}'::TIMESTAMPTZ - interval '7 days')").group('provider_id').to_sql}) requests on requests.provider_id = providers.id")
        .where.not(errors: { count: nil }).order(error_rate: :desc)
    end
  end
end
