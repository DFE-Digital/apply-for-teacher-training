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
    if record.provider
      record.site ||= record.provider.sites.find_by(code: value)
      record.errors.add(attr, "site #{value} does not exist for provider #{record.provider.code}") unless record.site
    end
  end

  validates_each :course_option do |record, attr, _value|
    if record.course && record.site
      record.course_option ||= record.course.course_options.find_by(
        study_mode: record.study_mode,
        site: record.site,
      )
      unless record.course_option
        record.errors.add(
          attr,
          "cannot find #{record.study_mode} option for course #{record.course.code} and site #{record.site.code}",
        )
      end
    end
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
end
