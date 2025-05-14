module ProviderInterface
  module FindCandidates
    class FiltersComponent < ViewComponent::Base
      include Rails.application.routes.url_helpers

      attr_accessor :params
      attr_reader :filter

      def initialize(params:, filter:)
        @params = params
        @filter = filter
      end

      def path_to_remove_location
        applied_filters = filter.applied_filters
        applied_filters.delete(:location)
        applied_filters.delete(:origin)

        provider_interface_candidate_pool_root_path(
          applied_filters,
        )
      end
    end
  end
end
