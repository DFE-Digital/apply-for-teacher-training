class ApplicationExperience < ApplicationRecord
  belongs_to :application_form, touch: true
  belongs_to :experienceable, polymorphic: true

  validates :role, :organisation, :start_date, presence: true

  def application_form=(application_form)
    super(application_form)

    self.experienceable = application_form
  end
end
