class ApplicationWorkExperience < ApplicationExperience
  belongs_to :application_form

  validates :commitment, presence: true

  enum commitment: {
    full_time: 'Full-time',
    part_time: 'Part-time',
  }
end
