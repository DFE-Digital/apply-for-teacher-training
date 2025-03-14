class CandidateInterface::LocationPreference < ApplicationRecord
  self.table_name = 'candidate_location_preferences'
  belongs_to :candidate_preference

  enum :status, {
    draft: 'draft',
    selected: 'selected',
    published: 'published',
  }
end
