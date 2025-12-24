class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :candidate, to: :session, allow_nil: true
  attribute :support_session
  attribute :provider_session
end
