module ProviderInterface
  module Reports
    class SubjectRowsBuilderService
      SECONDARY = 'Secondary'.freeze
      SECONDARY_SUBJECT = "#{SECONDARY} subject".freeze
      PRIMARY = 'Primary'.freeze
      LEVEL = 'Level'.freeze
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

      def subject_rows
        primary_level_row = rows.find { |row| row.level == LEVEL && row.title == PRIMARY }
        top_level_secondary_row = rows.find { |row| row.level == LEVEL && row.title == SECONDARY }
        secondary_subject_rows = rows.find_all { |row| row.level == SECONDARY_SUBJECT }&.sort_by(&:title)
        [primary_level_row, top_level_secondary_row, secondary_subject_rows].flatten.compact
      end

      def summary_row
        rows.find { |row| row.title == ALL && row.level == ALL }
      end

    private

      attr_reader :field_mapping, :provider_statistics, :statistics, :type

      def rows
        @rows ||= provider_statistics.map do |row|
          next if row_has_no_data?(row)

          national_row = statistics.find do |national_stat|
            stat_title = TYPE_OPTIONS[type][:stat_title]
            stat_level = TYPE_OPTIONS[type][:stat_level]
            [national_stat[stat_title], national_stat[stat_level]] == [row[title], row[level]]
          end

          next if national_row.blank?

          subject_from_row(row, national_row)
        end&.compact
      end

      def row_has_no_data?(row)
        # We never want to accidentally omit the summary row.
        return false if row[title] == ALL && row[level] == ALL

        # If this cycle and last cycle are both nil, 0, 0.0
        # blank? returns false for 0.0, but zero? returns true
        (row[this_cycle].nil? || row[this_cycle].zero?) &&
          (row[last_cycle].nil? || row[last_cycle].zero?)
      end

      def subject_from_row(row, national_row)
        SubjectRow.new(
          title: row[title],
          level: row[level],
          this_cycle: row[this_cycle],
          last_cycle: row[last_cycle],
          percentage_change: row[percentage_change],
          national_this_cycle: national_row[this_cycle],
          national_last_cycle: national_row[last_cycle],
          national_percentage_change: national_row[percentage_change],
        )
      end

      def title
        'nonprovider_filter'
      end

      def level
        'nonprovider_filter_category'
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
    end

    class SubjectRow
      include ActiveModel::Model

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
