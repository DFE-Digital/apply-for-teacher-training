class BreakInWorkHistoryComponent < ActionView::Component::Base
  attr_reader :break_in_months

  def initialize(work1:, work2:)
    @break_in_months = if work2 # is not last work entry
                         GetBreaksInMonths.call(work1.end_date, work2.start_date)
                       elsif work1.end_date # is not current job
                         GetBreaksInMonths.call(work1.end_date, nil)
                       else
                         0
                       end
  end
end
