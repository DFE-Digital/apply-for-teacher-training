class CourseOption < ApplicationRecord
  belongs_to :course
  belongs_to :site
  has_many :application_choices

  validates :vacancy_status, presence: true
  validate :validate_providers

  enum study_mode: {
    full_time: 'full_time',
    part_time: 'part_time',
  }

  def validate_providers
    return unless site.present? && course.present?

    return if site.provider == course.provider

    errors.add(:site, 'must have the same Provider as the course')
  end
end
