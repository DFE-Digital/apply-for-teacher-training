class GetCourseOptionFromCodes
  include ActiveModel::Validations
  attr_accessor :provider_code, :course_code, :recruitment_cycle_year, :study_mode, :site_code,
                :provider, :course, :site, :course_option

  # Using validates_each because validation for each attribute depends on the values of other attributes
  # The act of validation also performs the relevant lookups and memoizes the results, which are then used
  # in subsequent validations.

  validates_each :provider_code do |record, attr, value|
    record.provider ||= Provider.find_by(code: value)
    record.errors.add(attr, "provider #{value} does not exist") unless record.provider
  end

  validates_each :course_code do |record, attr, value|
    if record.provider
      record.course ||= record.provider.courses.find_by(
        code: value,
        recruitment_cycle_year: record.recruitment_cycle_year,
      )
      unless record.course
        record.errors.add(
          attr,
          "course #{value} does not exist for provider #{record.provider.code} and year #{record.recruitment_cycle_year}",
        )
      end
    end
  end

  validates_each :site_code do |record, attr, value|
    if record.provider && value.present?
      record.site ||= record.provider.sites.find_by(code: value)
      record.errors.add(attr, "site #{value} does not exist for provider #{record.provider.code}") unless record.site
    end
  end

  validates_each :course_option do |record, attr, _value|
    next unless record.course

    get_unique_course_option(record, attr)
  end

  def initialize(
    provider_code:,
    course_code:,
    study_mode:,
    site_code:,
    recruitment_cycle_year:
  )
    @provider_code = provider_code
    @course_code = course_code
    @study_mode = study_mode
    @site_code = site_code
    @recruitment_cycle_year = recruitment_cycle_year
  end

  def call
    course_option if valid?
  end

  def self.get_unique_course_option(record, attr)
    course_option_attrs = { study_mode: record.study_mode }

    course_option_attrs[:site] = record.site if record.site

    possible_course_options = record.course.course_options.where(course_option_attrs)

    if possible_course_options.count == 1
      record.course_option ||= possible_course_options.first
    else
      record.errors.add(attr, build_course_option_error_message(record, possible_course_options.count))
    end
  end

  def self.build_course_option_error_message(record, match_count)
    error_message = match_count.zero? ? 'cannot find any' : 'found multiple'

    error_message << " #{record.study_mode} options"
    error_message << " at site #{record.site.code}" if record.site
    error_message << " for course #{record.course.code}"
  end
end
