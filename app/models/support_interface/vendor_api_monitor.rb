module SupportInterface
  class VendorAPIMonitor
    def never_connected
      @_never_connected = providers.left_outer_joins(:vendor_api_requests)
        .includes(:vendor_api_tokens)
        .distinct
        .where(vendor_api_requests: { id: nil })
    end

    def no_sync_in_24h
      connected_providers.where.not(
        id: VendorAPIRequest.successful.syncs.select(:provider_id).distinct.where('created_at > ?', 24.hours.ago),
      ).map do |provider|
        ProviderWithAPIUsageStats.new(provider)
      end
    end

    def no_decisions_in_7d
      connected_providers.where.not(
        id: VendorAPIRequest.successful.decisions.select(:provider_id).distinct.where('created_at > ?', 7.days.ago),
      ).map do |provider|
        ProviderWithAPIUsageStats.new(provider)
      end
    end

    def providers_with_errors
      connected_providers.where(
        id: VendorAPIRequest.errors.select(:provider_id).distinct.where('created_at > ?', 7.days.ago),
      ).map do |provider|
        ProviderWithAPIUsageStats.new(provider)
      end
    end

  private

    def providers
      Provider.where(provider_type: 'university')
    end

    def connected_providers
      providers.where.not(id: never_connected)
    end
  end

  class ProviderWithAPIUsageStats < SimpleDelegator
    def last_sync
      vendor_api_requests.syncs.order(created_at: :desc).pick(:created_at)
    end

    def last_decision
      vendor_api_requests.decisions.order(created_at: :desc).pick(:created_at)
    end

    def error_count
      vendor_api_requests.errors.where('created_at > ?', 7.days.ago).count
    end

    def request_count
      vendor_api_requests.where('created_at > ?', 7.days.ago).count
    end

    def error_rate
      "#{((error_count.to_f / request_count) * 100).round(1)}%"
    end
  end
end
