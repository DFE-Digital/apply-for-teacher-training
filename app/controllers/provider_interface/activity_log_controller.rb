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

      if benchmark.real > 5
        Rails.logger.info(
          'Activity page slow for providers',
          activity_page_response: benchmark.real.round(2),
          activity_page_timeout: benchmark.real > 115,
          activity_page_providers: current_provider_user.providers.ids,
        )
      end
    end
  end
end
