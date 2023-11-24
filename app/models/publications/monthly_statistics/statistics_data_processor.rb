module Publications
  module MonthlyStatistics
    class StatisticsDataProcessor
      MINIMUM_GDPR_COMPLIANT_TOTAL = 3
      attr_reader :status_data

      def initialize(status_data:)
        @status_data = status_data
      end

      def violates_gdpr?
        totals[:this_cycle] < MINIMUM_GDPR_COMPLIANT_TOTAL ||
          totals[:last_cycle] < MINIMUM_GDPR_COMPLIANT_TOTAL
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
