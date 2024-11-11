module ProviderInterface
  class ActivityLogController < ProviderInterfaceController
    include Pagy::Backend

    PAGY_PER_PAGE = 50

    def index
      benchmark = Benchmark.measure do
        unless FeatureFlag.active?(:block_provider_activity_log)
          application_choices = GetApplicationChoicesForProviders.call(
            providers: current_provider_user.providers,
          )
          events = GetActivityLogEvents.call(application_choices:)
          @pagy, @events = pagy(events, limit: PAGY_PER_PAGE)
        end
      end

      provider_ids = current_provider_user.providers.ids.join(', ')
      if benchmark.real.between?(30, 115)
        Rails.logger.info "Activity page slow for providers [#{provider_ids}] took #{benchmark.real.to_i} seconds"
      end
      if benchmark.real > 115
        Rails.logger.info "Activity page timed out for providers [#{provider_ids}] took #{benchmark.real.to_i} seconds"
      end
    end
  end
end
