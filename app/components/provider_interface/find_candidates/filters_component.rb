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

      def path_to_remove_filter(filter_name, filter_value)
        case filter_name
        when 'location'
          path_to_remove_location
        else
          path_to_remove_filters(filter_name, filter_value)
        end
      end

      def subject_name(filter_value)
        filter.subject_options.find { |subject| subject.id == filter_value }&.name
      end

      def study_mode_name(filter_value)
        filter.study_mode_options.find { |subject| subject.value == filter_value }&.name
      end

      def course_type_name(filter_value)
        filter.course_type_options.find { |subject| subject.value == filter_value }&.name
      end

      def visa_sponsorship_name(filter_value)
        filter.visa_sponsorship_options.find { |subject| subject.value == filter_value }&.name
      end

    private

      def path_to_remove_location
        applied_filters = filter.applied_filters.clone
        applied_filters.delete(:location)
        applied_filters.delete(:origin)
        applied_filters[:remove_filter] = true

        to_query(applied_filters)
      end

      def path_to_remove_filters(filter_name, filter_value)
        applied_filters = filter.applied_filters.clone.with_indifferent_access
        applied_filters[filter_name] = applied_filters[filter_name].reject { |val| val == filter_value }
        applied_filters[:remove_filter] = true

        to_query(applied_filters)
      end

      def to_query(params)
        "?#{params.to_query}"
      end
    end
  end
end
