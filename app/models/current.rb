class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :candidate, to: :session, allow_nil: true
end
