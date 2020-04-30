class ApplicationExperience < ApplicationRecord
  validates :role, :organisation, :details, :start_date,
            presence: true

  validates :working_with_children, inclusion: { in: [true, false] }
end
