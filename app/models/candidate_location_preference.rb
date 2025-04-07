class CandidateLocationPreference < ApplicationRecord
  belongs_to :candidate_preference
  belongs_to :provider, optional: true
end
