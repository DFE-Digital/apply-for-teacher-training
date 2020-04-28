class CourseOption < ApplicationRecord
  belongs_to :course
  belongs_to :site
  has_many :application_choices

  audited associated_with: :provider
  delegate :provider, to: :course

  validates :vacancy_status, presence: true
  validate :validate_providers

  scope :selectable, -> { where(site_still_valid: true) }

  enum study_mode: {
    full_time: 'full_time',
    part_time: 'part_time',
  }

  enum vacancy_status: {
    vacancies: 'vacancies',
    no_vacancies: 'no_vacancies',
  }

  def validate_providers
    return unless site.present? && course.present?

    return if site.provider == course.provider

    errors.add(:site, 'must have the same Provider as the course')
  end

  def course_not_available?
    !course.exposed_in_find?
  end

  def course_closed_on_apply?
    !course.open_on_apply?
  end

  def course_full?
    course.course_options.vacancies.blank?
  end

  # >> Temporary methods - to be removed
  def invalidated_by_find=(value)
    self[:invalidated_by_find] = value
    if self.attributes.keys.include? 'site_still_valid'
      self[:site_still_valid] = !value
    end
  end

  def self.columns
    super.reject { |c| c.name == 'invalidated_by_find' }
  end
  # <<
end
