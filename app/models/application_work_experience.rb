class ApplicationWorkExperience < ApplicationExperience
  include TouchApplicationChoices

  validates :commitment, presence: true

  enum commitment: {
    full_time: 'Full time',
    part_time: 'Part time',
  }

  audited associated_with: :application_form
end
