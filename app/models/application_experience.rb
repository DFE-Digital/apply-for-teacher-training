class ApplicationExperience < ApplicationRecord
  belongs_to :experienceable, polymorphic: true, touch: true

  before_save -> { self.application_form_id = experienceable_id }, if: -> { application_form_id.nil? }

  after_commit do
    if application_form
      experienceable.touch_choices
    end
  end

  validates :role, :organisation, :start_date, presence: true

  audited associated_with: :experienceable

  def application_form
    experienceable if experienceable_type == 'ApplicationForm'
  end
end
