class ApplicationVolunteeringExperience < ApplicationExperience
  include TouchApplicationChoices

  audited associated_with: :application_form
end
