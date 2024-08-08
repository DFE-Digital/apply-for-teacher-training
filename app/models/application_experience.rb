class ApplicationExperience < ApplicationRecord
  belongs_to :experienceable, polymorphic: true, optional: true

  validates :role, :organisation, :start_date, presence: true
end
