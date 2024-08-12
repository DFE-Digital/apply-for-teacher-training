module Publications
  module MonthlyStatistics
    class StatisticsDataProcessor
      MINIMUM_GDPR_COMPLIANT_TOTAL = 3
      attr_reader :status_data

      def initialize(status_data:)
        @status_data = status_data
      end

      def violates_gdpr?
        @status_data[:this_cycle].to_i < MINIMUM_GDPR_COMPLIANT_TOTAL ||
        @status_data[:last_cycle].to_i < MINIMUM_GDPR_COMPLIANT_TOTAL
      end
    end
  end
end
