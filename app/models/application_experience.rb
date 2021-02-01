class ApplicationExperience < ApplicationRecord
  validates :role, :organisation, :start_date, presence: true
end
