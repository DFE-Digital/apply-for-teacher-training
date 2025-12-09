class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :candidate, to: :session, allow_nil: true

  attribute :dfe_session
  delegate :user, to: :session, allow_nil: true
end
