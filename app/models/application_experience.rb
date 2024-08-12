class ApplicationExperience < ApplicationRecord
  belongs_to :application_form, touch: true
  belongs_to :experienceable, polymorphic: true, optional: true

  before_save -> { self.experienceable = application_form }, if: -> { experienceable.nil? }

  validates :role, :organisation, :start_date, presence: true
end
