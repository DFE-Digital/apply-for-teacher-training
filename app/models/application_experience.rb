class ApplicationExperience < ApplicationRecord
  belongs_to :application_form, touch: true, optional: true
  belongs_to :experienceable, polymorphic: true

  validates :role, :organisation, :start_date, presence: true
end
