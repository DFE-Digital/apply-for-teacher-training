class ApplicationVolunteeringExperience < ApplicationExperience
  include PublishedInAPI

  belongs_to :application_form, touch: true

  audited associated_with: :application_form
end
