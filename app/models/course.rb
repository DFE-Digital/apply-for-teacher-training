class Course < ApplicationRecord
  belongs_to :provider
  has_many :course_options
  has_many :application_choices, through: :course_options
  has_many :sites, through: :course_options
  has_many :course_subjects
  has_many :subjects, through: :course_subjects
  has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year
  delegate :next_year?, to: :recruitment_cycle_timetable

  belongs_to :accredited_provider, class_name: 'Provider', optional: true

  validates :level, presence: true
  validates :code, uniqueness: { scope: %i[recruitment_cycle_year provider_id] }

  scope :exposed_in_find, -> { where(exposed_in_find: true) }
  scope :open_for_applications, -> { where('courses.applications_open_from <= ?', Time.zone.today) }
  scope :open, -> { application_status_open.exposed_in_find.where('courses.applications_open_from <= ?', Time.zone.today) }
  scope :current_cycle, -> { where(recruitment_cycle_year: RecruitmentCycleTimetable.current_year) }
  scope :previous_cycle, -> { where(recruitment_cycle_year: RecruitmentCycleTimetable.previous_year) }
  scope :in_cycle, ->(year) { where(recruitment_cycle_year: year) }
  scope :with_course_options_run_by_provider, ->(provider) { joins(:course_options).distinct.where(provider:) }
  scope :with_course_options, -> { left_outer_joins(:course_options).where.not(course_options: { id: nil }) }

  after_update :touch_application_choices_and_forms, if: :in_current_recruitment_cycle?

  CODE_LENGTH = 4
  SKE_GRADUATION_CUTOFF_THRESHOLD = 5.years

  # This enum is copied verbatim from Find to maintain consistency
  enum :application_status, {
    closed: 0,
    open: 1,
  }, prefix: :application_status

  enum :level, {
    primary: 'Primary',
    secondary: 'Secondary',
    further_education: 'Further education',
  }, suffix: :course

  enum :funding_type, {
    fee: 'fee',
    salary: 'salary',
    apprenticeship: 'apprenticeship',
  }

  # also copied from Find
  enum :study_mode, {
    full_time: 'F',
    part_time: 'P',
    full_time_or_part_time: 'B',
  }

  # also copied from Find
  enum :program_type, {
    higher_education_programme: 'HE',
    higher_education_salaried_programme: 'HES',
    school_direct_training_programme: 'SD',
    school_direct_salaried_training_programme: 'SS',
    scitt_programme: 'SC',
    scitt_salaried_programme: 'SSC',
    pg_teaching_apprenticeship: 'TA',
    teacher_degree_apprenticeship: 'TDA',
  }

  enum :degree_grade, {
    two_one: 'two_one',
    two_two: 'two_two',
    third_class: 'third_class',
    not_required: 'not_required',
  }

  def name_and_description
    "#{name} #{description_to_s}"
  end

  def name_provider_and_description
    "#{name} #{accredited_provider&.name} #{description_to_s}"
  end

  def year_name_and_code
    "#{recruitment_cycle_year}: #{name} (#{code})"
  end

  def name_and_code
    "#{name} (#{code})"
  end

  def name_code_and_description
    "#{name} (#{code}) – #{description_to_s}"
  end

  def name_code_and_provider
    "#{name} (#{code}) – #{accredited_provider&.name}"
  end

  def name_code_and_age_range
    "#{name}, #{age_range} (#{code})"
  end

  def name_description_provider_and_age_range
    "#{name} #{description_to_s} #{accredited_provider&.name} #{age_range}"
  end

  def provider_and_name_code
    "#{provider.name} – #{name_and_code}"
  end

  def description_and_accredited_provider
    accredited_provider ? "#{description_to_s} - #{accredited_provider&.name}" : description_to_s
  end

  def name_code_and_course_provider
    "#{name} (#{code}) – #{provider.name}"
  end

  def currently_has_both_study_modes_available?
    available_study_modes_with_vacancies.count == 2
  end

  def available_study_modes_with_vacancies
    course_options.available.pluck(:study_mode).uniq
  end

  def full?
    course_options.vacancies.blank?
  end

  def available?
    course_options.available.present?
  end

  def not_available?
    !exposed_in_find
  end

  def open?
    applications_open_from.present? && applications_open_from <= Time.zone.today && exposed_in_find && application_status_open?
  end

  def open_for_applications?
    applications_open_from <= Time.zone.today
  end

  def find_url
    url = if HostingEnvironment.sandbox_mode?
            I18n.t('find_teacher_training.sandbox_url')
          else
            I18n.t('find_teacher_training.production_url')
          end

    "#{url}course/#{provider.code}/#{code}"
  end

  def in_previous_cycle
    Course.find_by(recruitment_cycle_year: recruitment_cycle_year - 1, provider_id:, code:)
  end

  def in_next_cycle
    Course.find_by(recruitment_cycle_year: recruitment_cycle_year + 1, provider_id:, code:)
  end

  def application_forms
    ApplicationForm
      .includes(:candidate, :application_choices)
      .joins(application_choices: :course_option)
      .where(application_choices: { course_options: { course: self } })
      .distinct
  end

  def subject_codes
    @subject_codes ||= subjects.includes(:course_subjects).map(&:code)
  end

  def study_modes
    study_mode.split('_or_')
  end

  def ratifying_provider
    accredited_provider || provider
  end

  def ske_graduation_cutoff_date
    start_date - SKE_GRADUATION_CUTOFF_THRESHOLD
  end

  def multiple_sites?
    course_options.available.pluck(:site_id).uniq.many?
  end

  def qualifications_to_s
    return '' if qualifications.blank?

    case qualifications.sort
    in ['pgce', 'qts'] then 'QTS with PGCE'
    in ['pgde', 'qts'] then 'QTS with PGDE'
    in ['qts', 'undergraduate_degree'] then description
    else
      qualifications.first.upcase
    end
  end

  def description_to_s
    # This terminology comes directly from Publish API inside the description
    # and we need to invert when we show in Apply.
    @description_to_s ||= description.to_s.gsub('PGCE with QTS', 'QTS with PGCE').gsub('PGDE with QTS', 'QTS with PGDE')
  end

  def undergraduate?
    teacher_degree_apprenticeship?
  end

  def course_type
    return I18n.t('course_types.undergraduate') if undergraduate?

    I18n.t('course_types.postgraduate')
  end

  def does_not_require_degree?
    undergraduate? || !degree_grade?
  end

  def deferred_start_date
    start_date + 1.year
  end

private

  def touch_application_choices_and_forms
    return if saved_changes['start_date'].blank?

    ActiveRecord::Base.transaction do
      application_choices.touch_all
      ApplicationForm.where(application_choices:).touch_all
    end
  end

  def in_current_recruitment_cycle?
    recruitment_cycle_timetable.current_year?
  end
end
