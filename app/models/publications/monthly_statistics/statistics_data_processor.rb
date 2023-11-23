module Publications
  module MonthlyStatistics
    class StatisticsDataProcessor
      LOWER_STATS_THAT_VIOLATES_GDPR = 3
      attr_reader :status_data

      def initialize(status_data:)
        @status_data = status_data
      end

      def violates_gdpr?
        totals[:this_cycle] < LOWER_STATS_THAT_VIOLATES_GDPR ||
          totals[:last_cycle] < LOWER_STATS_THAT_VIOLATES_GDPR
      end

    private

      def totals
        return @status_data if headline_statistics?

        {
          this_cycle: @status_data.sum { |data| data[:this_cycle] },
          last_cycle: @status_data.sum { |data| data[:last_cycle] },
        }
      end

      def headline_statistics?
        @status_data.is_a?(Hash)
      end
    end
  end
end
