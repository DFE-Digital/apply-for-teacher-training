class ApplicationWorkExperience < ApplicationExperience
  include TouchApplicationChoices

  belongs_to :application_form, touch: true

  after_save -> { update!(experienceable: application_form) }, if: -> { experienceable.nil? }

  validates :commitment, presence: true

  enum commitment: {
    full_time: 'Full time',
    part_time: 'Part time',
  }

  audited associated_with: :application_form ## is this an issue?
end
