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

      def filters
        {
          subject_ids: {
            options: subject_options,
          },
          study_mode: {
            options: study_mode_options,
          },
          course_type: {
            options: course_type_options,
          },
          visa_sponsorship: {
            options: visa_sponsorship_options,
          },
        }.with_indifferent_access
      end

      def option_name(filter_name, filter_value)
        filters[filter_name][:options].find { |filter| filter.value == filter_value }&.name
      end

      def subject_options
        subjects = Subject.select("name, string_agg(id::text, ',') as id").group(:name).order(:name)
        struct = Struct.new(:name, :value)

        subjects.map do |subject|
          struct.new(
            value: subject.id.to_s,
            name: subject.name,
          )
        end
      end

      def visa_sponsorship_options
        visa = Struct.new(:value, :name)

        [['required', 'Needs a visa'], ['not required', 'Does not need a visa']].map do |value, name|
          visa.new(
            value:,
            name:,
          )
        end
      end

      def study_mode_options
        study_mode = Struct.new(:value, :name)

        CourseOption.study_modes.map do |_, value|
          study_mode.new(
            value: value,
            name: value.split('_').join(' ').capitalize,
          )
        end
      end

      def course_type_options
        course_type = Struct.new(:value, :name)

        %w[undergraduate postgraduate].map do |value|
          course_type.new(
            value: value,
            name: value.capitalize,
          )
        end
      end

    private

      def path_to_remove_location
        applied_filters = filter.applied_filters.clone
        applied_filters.delete(:location)
        applied_filters.delete(:origin)
        applied_filters[:remove_filters] = true

        to_query(applied_filters)
      end

      def path_to_remove_filter(filter_name, filter_value)
        applied_filters = filter.applied_filters.clone.with_indifferent_access
        applied_filters[filter_name] = applied_filters[filter_name].reject { |val| val == filter_value }
        applied_filters[:remove_filters] = true

        to_query(applied_filters)
      end

      def to_query(params)
        "?#{params.to_query}"
      end
    end
  end
end
