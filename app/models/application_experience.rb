class ApplicationExperience < ApplicationRecord
  self.ignored_columns += %w[experienceable_type experienceable_id]

  validates :role, :organisation, :start_date, presence: true
end
