class BreakInWorkHistoryComponent < ActionView::Component::Base
  include ViewHelper

  attr_reader :work_break

  def initialize(work_break:, editable: true)
    @work_break = work_break
    @editable = editable
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
      action: "description for break between #{formatted_start_date} and #{formatted_end_date}",
      change_path: candidate_interface_edit_work_history_break_path(@work_break),
    }
  end

  def dates_row
    {
      key: 'Dates',
      value: "#{formatted_start_date} - #{formatted_end_date}",
      action: "dates for break between #{formatted_start_date} and #{formatted_end_date}",
      change_path: candidate_interface_edit_work_history_break_path(@work_break),
    }
  end
end
