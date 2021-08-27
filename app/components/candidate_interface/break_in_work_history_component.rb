module CandidateInterface
  class BreakInWorkHistoryComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :work_break

    def initialize(work_break:, editable: true, heading_level: 2)
      @work_break = work_break
      @editable = editable
      @heading_level = heading_level
    end

    def work_break_rows
      [reason_row, dates_row]
    end

    def formatted_start_date
      @work_break.start_date.to_s(:month_and_year)
    end

    def formatted_end_date
      @work_break.end_date.to_s(:month_and_year)
    end

  private

    def reason_row
      {
        key: 'Description',
        value: @work_break.reason,
        action: {
          href: candidate_interface_edit_work_history_break_path(@work_break),
          visually_hidden_text: "description for break between #{formatted_start_date} and #{formatted_end_date}",
        },
      }
    end

    def dates_row
      {
        key: 'Dates',
        value: "#{formatted_start_date} - #{formatted_end_date}",
        action: {
          href: candidate_interface_edit_work_history_break_path(@work_break),
          visually_hidden_text: "dates for break between #{formatted_start_date} and #{formatted_end_date}",
        },
      }
    end
  end
end
