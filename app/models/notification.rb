class Notification < ApplicationRecord
  belongs_to :notified, polymorphic: true

  enum :notification_type, {
    pool_opt_in: 'pool_opt_in',
  }
end
