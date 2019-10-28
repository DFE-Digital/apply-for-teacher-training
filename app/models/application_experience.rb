class ApplicationExperience < ApplicationRecord
  validates :role, :organisation, :details, :start_date,
            presence: true

  validates_inclusion_of :working_with_children, in: [true, false]
end
