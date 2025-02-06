class Current < ActiveSupport::CurrentAttributes
  attribute :session, :timetable, :cycle_year
  delegate :candidate, to: :session, allow_nil: true
end
