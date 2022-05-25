class CourseOption < ApplicationRecord
  belongs_to :course
  belongs_to :site, class_name: 'TempSite', foreign_key: 'temp_site_id'
  belongs_to :old_site, class_name: 'Site', foreign_key: 'site_id', optional: true
  has_many :application_choices

  audited associated_with: :provider
  delegate :provider, to: :course
  delegate :accredited_provider, to: :course
  delegate :name, :full_address, to: :site, prefix: true

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

  scope :available, lambda {
    selectable.where(vacancy_status: 'vacancies')
  }

  delegate :full?, :withdrawn?, :closed_on_apply?, :not_available?, to: :course, prefix: true

  def no_vacancies?
    vacancy_status == 'no_vacancies'
  end

  def validate_providers
    return unless site.present? && course.present?

    return if site.provider == course.provider

    errors.add(:site, 'must have the same Provider as the course')
  end

  def in_previous_cycle
    equivalent_course = course.in_previous_cycle

    if equivalent_course
      CourseOption.find_by(
        course: equivalent_course,
        site: site,
        study_mode: study_mode,
      )
    end
  end

  def in_next_cycle
    equivalent_course = course.in_next_cycle

    if equivalent_course
      CourseOption.find_by(
        course: equivalent_course,
        site: site,
        study_mode: study_mode,
      )
    end
  end
end
