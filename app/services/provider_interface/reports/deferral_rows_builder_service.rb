module ProviderInterface
  module Reports
    class DeferralRowsBuilderService
      ALL = 'All'.freeze
      def initialize(field_mapping:, provider_statistics:, national_statistics:)
        @field_mapping = field_mapping
        @provider_statistics = provider_statistics
        @national_statistics = national_statistics
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
        @national_summary_data ||= @national_statistics.find do |row|
          row[title] == ALL && row[level] == ALL
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
