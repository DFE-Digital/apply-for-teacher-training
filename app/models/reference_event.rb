class ReferenceEvent < ApplicationRecord
  belongs_to :application_reference

  enum name: {
    request_sent: 'request_sent',
    request_cancelled: 'request_cancelled',
    request_bounced: 'request_bounced',
    reminder_sent: 'reminder_sent',
    declined: 'declined',
    given: 'given',
  }
end
