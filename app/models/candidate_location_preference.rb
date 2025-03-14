class CandidateLocationPreference < ApplicationRecord
  belongs_to :candidate_preference

  enum :status, {
    draft: 'draft',
    selected: 'selected',
    published: 'published',
  }
end
