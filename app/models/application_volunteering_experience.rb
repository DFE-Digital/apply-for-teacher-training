class ApplicationVolunteeringExperience < ApplicationExperience
  belongs_to :application_form

  audited associated_with: :application_form
end
