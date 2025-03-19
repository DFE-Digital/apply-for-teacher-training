class CandidatePreference < ApplicationRecord
  belongs_to :candidate
  has_many :location_preferences, dependent: :destroy, class_name: 'CandidateLocationPreference'

  enum :pool_status, {
    opt_in: 'opt_in',
    opt_out: 'opt_out',
  }

  enum :status, {
    draft: 'draft',
    published: 'published',
  }
end
