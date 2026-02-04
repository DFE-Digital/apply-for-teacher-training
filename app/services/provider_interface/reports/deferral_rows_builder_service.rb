module ProviderInterface
  module Reports
    class DeferralRowsBuilderService
      ALL = 'All'.freeze
      TYPE_OPTIONS = {
        NATIONAL: {
          stat_title: 'nonprovider_filter',
          stat_level: 'nonprovider_filter_category',
        },
        REGIONAL: {
          stat_title: 'nonregion_filter',
          stat_level: 'nonregion_filter_category',
        },
      }.freeze

      def initialize(field_mapping:, provider_statistics:, statistics:, type:)
        @field_mapping = field_mapping
        @provider_statistics = provider_statistics
        @statistics = statistics
        @type = type
      end

      def deferral_rows
        @deferral_rows ||=
          if provider_summary_data.empty? || national_summary_data.empty?
            []
          else
            [{
              title: :deferrals_this_cycle_to_next,
              provider_deferrals_count: provider_summary_data[this_cycle],
              national_deferrals_count: national_summary_data[this_cycle],
            }, {
              title: :deferrals_last_cycle_to_this_cycle,
              provider_deferrals_count: provider_summary_data[last_cycle],
              national_deferrals_count: national_summary_data[last_cycle],
            }].map { |row| DeferralRow.new(**row) }
          end
      end

    private

      def provider_summary_data
        @provider_summary_data ||= @provider_statistics.find do |row|
          row[title] == ALL && row[level] == ALL
        end
      end

      def national_summary_data
        @national_summary_data ||= @statistics.find do |row|
          stat_title = TYPE_OPTIONS[@type][:stat_title]
          stat_level = TYPE_OPTIONS[@type][:stat_level]
          row[stat_title] == ALL && row[stat_level] == ALL
        end
      end

      def title
        'nonprovider_filter'
      end

      def level
        'nonprovider_filter_category'
      end

      def this_cycle
        @field_mapping.with_indifferent_access[:this_cycle]
      end

      def last_cycle
        @field_mapping.with_indifferent_access[:last_cycle]
      end
    end

    class DeferralRow
      include ActiveModel::Model

      attr_accessor :title,
                    :provider_deferrals_count,
                    :national_deferrals_count
      def initialize(**attributes)
        assign_attributes(**attributes)
      end
    end
  end
end
