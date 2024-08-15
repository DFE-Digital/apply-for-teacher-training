class ApplicationExperience < ApplicationRecord
  belongs_to :application_form, touch: true, optional: true
  belongs_to :experienceable, polymorphic: true

  before_save -> { self.application_form_id = experienceable_id }, if: -> { application_form_id.nil? }

  validates :role, :organisation, :start_date, presence: true

  def application_form=(value)
    super
    self.experienceable = value
  end
end
