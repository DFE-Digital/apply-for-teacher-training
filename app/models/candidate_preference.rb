class CandidatePreference < ApplicationRecord
  # Need this table because we have a multi step form now, so we cannot save on candidate model.

  belongs_to :candidate
  has_many :location_preferences, dependent: :destroy, class_name: 'CandidateLocationPreference'

  enum :status, { draft: 'draft', published: 'published' }
  enum :pool_status, { opt_in: 'opt_in', opt_out: 'opt_out' }
end
