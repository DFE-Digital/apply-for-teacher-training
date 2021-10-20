class ApplicationVolunteeringExperience < ApplicationExperience
  include TouchApplicationChoices

  belongs_to :application_form, touch: true

  audited associated_with: :application_form
end
