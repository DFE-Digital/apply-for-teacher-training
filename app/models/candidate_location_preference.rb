class CandidateLocationPreference < ApplicationRecord
  belongs_to :candidate_preference
  belongs_to :provider, optional: true

  acts_as_mappable lat_column_name: :latitude, lng_column_name: :longitude

  geocoded_by :name
end
