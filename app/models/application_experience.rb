class ApplicationExperience < ApplicationRecord
  validates :role, :organisation, :details, :working_with_children, :start_date,
            presence: true
end
