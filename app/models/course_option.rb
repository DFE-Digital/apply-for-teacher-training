class CourseOption < ApplicationRecord
  belongs_to :course
  belongs_to :site
  has_many :application_choices
  has_many :current_application_choices, class_name: 'ApplicationChoice', foreign_key: :current_course_option, inverse_of: :current_course_option

  audited associated_with: :provider
  delegate :provider, to: :course
  delegate :accredited_provider, to: :course
  delegate :name, :full_address, :postcode, to: :site, prefix: true

  validates :vacancy_status, presence: true
  validate :validate_providers

  scope :selectable, -> { where(site_still_valid: true) }

  enum :study_mode, {
    full_time: 'full_time',
    part_time: 'part_time',
  }

  enum :vacancy_status, {
    vacancies: 'vacancies',
    no_vacancies: 'no_vacancies',
  }

  scope :available, lambda {
    selectable.where(vacancy_status: 'vacancies')
  }

  delegate :full?, :withdrawn?, :application_status_closed?, :not_available?, to: :course, prefix: true

  def no_vacancies?
    vacancy_status == 'no_vacancies'
  end

  def validate_providers
    return unless site.present? && course.present?

    return if site.provider == course.provider

    errors.add(:site, 'must have the same Provider as the course')
  end

  def in_previous_cycle
    year = course.recruitment_cycle_year - 1
    equivalent_course = course.in_previous_cycle
    equivalent_sites = equivalent_site_for_years([year])

    if equivalent_course && equivalent_sites.any?
      CourseOption.find_by(
        course: equivalent_course,
        site: equivalent_sites,
        study_mode:,
      )
    end
  end

  def in_next_cycle
    year = course.recruitment_cycle_year + 1
    equivalent_course = course.in_next_cycle
    equivalent_sites = equivalent_site_for_years([year])

    if equivalent_course && equivalent_sites.any?
      CourseOption.find_by(
        course: equivalent_course,
        site: equivalent_sites,
        study_mode:,
      )
    end
  end

  def full_time?
    study_mode == 'full_time'
  end

  def part_time?
    study_mode == 'part_time'
  end

  def self.find_through_api(course_data)
    criteria = {
      study_mode: course_data[:study_mode],
      courses: {
        providers: { code: course_data[:provider_code] },
        code: course_data[:course_code],
        recruitment_cycle_year: course_data[:recruitment_cycle_year],
      },
    }

    if course_data[:site_code].present?
      criteria[:sites] = {
        providers: { code: course_data[:provider_code] },
        code: course_data[:site_code],
      }
    end

    CourseOption
      .joins(course: :provider)
      .joins(site: :provider)
      .find_by!(criteria)
  end

private

  def equivalent_site_for_years(years)
    site.provider.sites.for_recruitment_cycle_years(years).where(code: site.code)
  end
end
