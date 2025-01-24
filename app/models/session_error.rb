class SessionError < ApplicationRecord
  belongs_to :candidate, optional: true

  enum :error_type, {
    internal: 'internal',
    wrong_email_address: 'wrong_email_address',
  }
end
