class GetCourseOptionFromCodes
  include ActiveModel::Validations

  LOCALE_PREFIX = 'activemodel.errors.models.get_course_option_from_codes.attributes'.freeze

  attr_accessor :provider_code, :course_code, :recruitment_cycle_year, :study_mode, :site_code,
                :provider, :course, :site, :course_option

  validates_presence_of :provider_code, :course_code, :study_mode, :recruitment_cycle_year

  # Using validates_each because validation for each attribute depends on the values of other attributes
  # The act of validation also performs the relevant lookups and memoizes the results, which are then used
  # in subsequent validations.

  validates_each :provider_code do |record, attr, value|
    next if record.provider_code.blank?

    record.provider ||= Provider.find_by(code: value)
    record.errors.add(attr, "Provider #{value} does not exist") unless record.provider
  end

  validates_each :course_code do |record, attr, value|
    next if record.course_code.blank? || record.recruitment_cycle_year.blank?

    if record.provider
      record.course ||= record.provider.courses.find_by(
        code: value,
        recruitment_cycle_year: record.recruitment_cycle_year,
      )
      unless record.course
        record.errors.add(
          attr,
          "Course #{value} does not exist for provider #{record.provider.code} and year #{record.recruitment_cycle_year}",
        )
      end
    end
  end

  validates_each :site_code do |record, attr, value|
    if record.provider && value.present?
      validate_site_unique(record, attr, value)
    end
  end

  validates_each :course_option do |record, attr, _value|
    next if record.course.blank? || record.study_mode.blank?

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

    possible_course_options = record.course.course_options.selectable.where(course_option_attrs)

    if possible_course_options.count == 1
      record.course_option ||= possible_course_options.first
    else
      record.errors.add(attr, build_course_option_error_message(record, possible_course_options.count))
    end
  end

  def self.build_course_option_error_message(record, match_count)
    error_message = match_count.zero? ? 'Cannot find any' : 'Found multiple'

    error_message << " #{record.study_mode} options"
    error_message << " at site #{record.site.code}" if record.site
    error_message << " for course #{record.course.code}"
  end

  def self.validate_site_unique(record, attr, value)
    current_year = RecruitmentCycleTimetable.current_year
    sites = record
      .provider.sites
      .joins(:course_options)
      .merge(CourseOption.selectable)
      .for_recruitment_cycle_years([current_year])
      .where(code: value)

    if sites.count > 1
      record.errors.add(
        attr,
        I18n.t("#{LOCALE_PREFIX}.site_code.multiple", code: value, provider: record.provider.code),
      )
    else
      record.site ||= sites.first
      error_message = I18n.t("#{LOCALE_PREFIX}.site_code.blank", code: value, provider: record.provider.code, year: current_year)
      record.errors.add(attr, error_message) unless record.site
    end
  end
end
