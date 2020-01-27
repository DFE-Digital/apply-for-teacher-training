class BreakInWorkHistoryComponent < ActionView::Component::Base
  attr_reader :break_in_months

  def initialize(application_form:, work_experience:)
    @break_in_months = GetBreaksInWorkHistory
                         .call(application_form)
                         .fetch(work_experience.id, 0)
  end
end
