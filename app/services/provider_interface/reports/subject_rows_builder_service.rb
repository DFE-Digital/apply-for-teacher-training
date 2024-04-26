module ProviderInterface
  module Reports
    class SubjectRowsBuilderService
      SECONDARY = 'Secondary'.freeze
      SECONDARY_SUBJECT = "#{SECONDARY} subject".freeze
      PRIMARY = 'Primary'.freeze
      LEVEL = 'Level'.freeze

      def initialize(field_mapping:, provider_statistics:, national_statistics:)
        @field_mapping = field_mapping
        @provider_statistics = provider_statistics
        @national_statistics = national_statistics
      end

      def subject_rows
        primary_level_row = rows.find { |row| row.level == LEVEL && row.title == PRIMARY }
        top_level_secondary_row = rows.find { |row| row.level == LEVEL && row.title == SECONDARY }
        secondary_subject_rows = rows.find_all { |row| row.level == SECONDARY_SUBJECT }&.sort_by(&:title)
        [primary_level_row, top_level_secondary_row, secondary_subject_rows].flatten.compact
      end

      def summary_row
        rows.find { |row| row.title == 'All' && row.level == 'All' }
      end

    private

      def rows
        @rows ||= provider_statistics.map do |row|
          next if row[this_cycle].blank? && row[last_cycle].blank?

          national_row = national_statistics.find do |national_stat|
            [national_stat[title], national_stat[level]] == [row[title], row[level]]
          end

          next if national_row.blank?

          subject_from_row(row, national_row)
        end&.compact
      end

      attr_reader :field_mapping, :provider_statistics, :national_statistics

      def subject_from_row(row, national_row)
        SubjectRow.new(
          title: row[title],
          level: row[level],
          percentage_change: row[percentage_change] || nil,
          this_cycle: row[this_cycle],
          last_cycle: row[last_cycle],
          national_this_cycle: national_row[this_cycle] || 'Not available',
          national_last_cycle: national_row[last_cycle] || 'Not available',
          national_percentage_change: national_row[percentage_change] || nil,
        )
      end

      def this_cycle
        field_mapping.with_indifferent_access[:this_cycle]
      end

      def last_cycle
        field_mapping.with_indifferent_access[:last_cycle]
      end

      def percentage_change
        field_mapping.with_indifferent_access[:percentage_change]
      end

      def title
        'nonprovider_filter'
      end

      def level
        'nonprovider_filter_category'
      end

      def include_percentage_change?
        field_mapping.keys(&:to_sym).include? :percentage_change
      end
    end

    class SubjectRow
      include ActiveRecord::AttributeAssignment
      attr_accessor :title,
                    :level,
                    :this_cycle,
                    :last_cycle,
                    :percentage_change,
                    :national_this_cycle,
                    :national_last_cycle,
                    :national_percentage_change

      def initialize(**attributes)
        assign_attributes(**attributes)
      end
    end
  end
end
