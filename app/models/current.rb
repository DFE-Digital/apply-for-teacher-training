class Current < ActiveSupport::CurrentAttributes
  attribute :session, :cycle_timetable, :next_cycle_timetable, :cycle_year, :previous_cycle_year, :next_cycle_year, :cycle_week
  delegate :candidate, to: :session, allow_nil: true
end
