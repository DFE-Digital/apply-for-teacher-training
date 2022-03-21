module CandidateInterface
  class BreakPlaceholderInWorkHistoryComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :work_break

    def initialize(work_break:, heading_level: 2)
      @work_break = work_break
      @heading_level = heading_level
    end

    def between_formatted_dates
      "between #{@work_break.start_date.to_fs(:month_and_year)} and #{@work_break.end_date.to_fs(:month_and_year)}"
    end
  end
end
