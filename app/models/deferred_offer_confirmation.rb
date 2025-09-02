class DeferredOfferConfirmation < ApplicationRecord
  belongs_to :provider_user
  belongs_to :offer
  belongs_to :course, optional: true
  belongs_to :location, optional: true, class_name: 'Site', foreign_key: 'site_id'

  enum :study_mode, { full_time: 'full_time', part_time: 'part_time' },
       validate: { allow_nil: true },
       instance_methods: false,
       scopes: false

  enum :conditions_status, { met: 'met', pending: 'pending' },
       validate: { allow_nil: true },
       instance_methods: false,
       scopes: false
end
