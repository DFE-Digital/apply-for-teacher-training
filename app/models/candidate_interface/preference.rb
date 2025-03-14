class CandidateInterface::Preference < ApplicationRecord
  self.table_name = 'candidate_preferences'
  belongs_to :candidate
  has_many :location_preferences, dependent: :destroy, class_name: 'CandidateInterface::LocationPreference', foreign_key: 'candidate_preference_id'

  enum :status, { draft: 'draft', published: 'published' }
  enum :pool_status, { opt_in: 'opt_in', opt_out: 'opt_out' }
end
