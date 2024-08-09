class ApplicationVolunteeringExperience < ApplicationExperience
  include TouchApplicationChoices

  belongs_to :application_form, touch: true

  after_save -> { update!(experienceable: application_form) }, if: -> { experienceable.nil? }

  audited associated_with: :application_form ## is this an issue?
end
