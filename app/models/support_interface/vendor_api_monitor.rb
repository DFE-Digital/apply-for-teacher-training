module SupportInterface
  class VendorAPIMonitor
    def providers_with_api_usage_stats
      Provider.select('providers.id,
                      providers.name,
                      last_syncs.last_sync as last_sync,
                      last_decisions.last_decision as last_decision,
                      errors.count as error_count,
                      requests.count as request_count,
                      all_time_requests.count,
                      (CAST(errors.count AS FLOAT)/requests.count) * 100 as error_rate')
        .joins("LEFT JOIN (#{VendorAPIRequest.successful.syncs.select('provider_id, MAX(vendor_api_requests.created_at) as last_sync').group('provider_id').to_sql}) last_syncs on last_syncs.provider_id = providers.id")
        .joins("LEFT JOIN (#{VendorAPIRequest.successful.decisions.select('provider_id, MAX(vendor_api_requests.created_at) as last_decision').group('provider_id').to_sql}) last_decisions on last_decisions.provider_id = providers.id")
        .joins("LEFT JOIN (#{VendorAPIRequest.errors.select('provider_id, COUNT(vendor_api_requests.id) as count').where("vendor_api_requests.created_at > current_date - interval '7 days'").group('provider_id').to_sql}) errors on errors.provider_id = providers.id")
        .joins("LEFT JOIN (#{VendorAPIRequest.select('provider_id, COUNT(vendor_api_requests.id) as count').where("vendor_api_requests.created_at > current_date - interval '7 days'").group('provider_id').to_sql}) requests on requests.provider_id = providers.id").where(provider_type: 'university')
        .joins("LEFT JOIN (#{VendorAPIRequest.select('provider_id, COUNT(vendor_api_requests.id) as count').group('provider_id').to_sql}) all_time_requests on all_time_requests.provider_id = providers.id").where(provider_type: 'university')
    end

    def never_connected
      providers_with_api_usage_stats
        .includes(:vendor_api_tokens)
        .where(all_time_requests: { count: nil })
    end

    def no_sync_in_24h
      providers_with_api_usage_stats.where("last_sync < now() - interval '24 hours'").order('last_sync DESC')
    end

    def no_decisions_in_7d
      providers_with_api_usage_stats.where("last_decision < now() - interval '7 days'").order('last_decision DESC')
    end

    def providers_with_errors
      providers_with_api_usage_stats.where.not(errors: { count: nil }).order('error_rate DESC')
    end

    alias all_providers providers_with_api_usage_stats
  end
end
