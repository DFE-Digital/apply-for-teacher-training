module CandidateInterface
  module RestructuredWorkHistory
    class GapComponent < ViewComponent::Base
      include ViewHelper

      def initialize(break_period:)
        @break_period = break_period
      end

      def between_formatted_dates
        "between #{@break_period.start_date.to_s(:month_and_year)} and #{@break_period.end_date.to_s(:month_and_year)}"
      end
    end
  end
end
