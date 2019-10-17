class CourseOption < ApplicationRecord
  belongs_to :course
  belongs_to :site
  has_many :application_choices

  validates :vacancy_status, presence: true
  validate :validate_providers, if: -> { site.present? && course.present? }

  def validate_providers
    return if site.provider == course.provider

    errors.add(:site, 'must have the same Provider as the course')
  end
end
