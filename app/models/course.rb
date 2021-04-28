class Course < ApplicationRecord
  belongs_to :provider
  has_many :course_options
  has_many :application_choices, through: :course_options
  has_many :sites, through: :course_options
  has_many :course_subjects
  has_many :subjects, through: :course_subjects
  belongs_to :accredited_provider, class_name: 'Provider', optional: true

  audited associated_with: :provider

  validates :level, presence: true
  validates :code, uniqueness: { scope: %i[recruitment_cycle_year provider_id] }

  scope :open_on_apply, -> { exposed_in_find.where(open_on_apply: true) }
  scope :exposed_in_find, -> { where(exposed_in_find: true) }
  scope :current_cycle, -> { where(recruitment_cycle_year: RecruitmentCycle.current_year) }
  scope :previous_cycle, -> { where(recruitment_cycle_year: RecruitmentCycle.previous_year) }
  scope :in_cycle, ->(year) { where(recruitment_cycle_year: year) }

  scope :with_course_options, -> { left_outer_joins(:course_options).where('course_options.id IS NOT NULL') }
  CODE_LENGTH = 4

  # This enum is copied verbatim from Find to maintain consistency
  enum level: {
    primary: 'Primary',
    secondary: 'Secondary',
    further_education: 'Further education',
  }, _suffix: :course

  enum funding_type: {
    fee: 'fee',
    salary: 'salary',
    apprenticeship: 'apprenticeship',
  }

  # also copied from Find
  enum study_mode: {
    full_time: 'F',
    part_time: 'P',
    full_time_or_part_time: 'B',
  }

  # also copied from Find
  enum program_type: {
    higher_education_programme: 'HE',
    school_direct_training_programme: 'SD',
    school_direct_salaried_training_programme: 'SS',
    scitt_programme: 'SC',
    pg_teaching_apprenticeship: 'TA',
  }

  def name_and_description
    "#{name} #{description}"
  end

  def name_provider_and_description
    "#{name} #{accredited_provider&.name} #{description}"
  end

  def year_name_and_code
    "#{recruitment_cycle_year}: #{name} (#{code})"
  end

  def name_and_code
    "#{name} (#{code})"
  end

  def name_code_and_description
    "#{name} (#{code}) – #{description}"
  end

  def name_code_and_provider
    "#{name} (#{code}) – #{accredited_provider&.name}"
  end

  def name_code_and_age_range
    "#{name} (#{code}) – #{age_range}"
  end

  def name_description_provider_and_age_range
    "#{name} #{description} #{accredited_provider&.name} #{age_range}"
  end

  def provider_and_name_code
    "#{provider.name} - #{name_and_code}"
  end

  def currently_has_both_study_modes_available?
    available_study_modes_with_vacancies.count == 2
  end

  def supports_study_mode?(mode)
    available_study_modes_from_options.include?(mode)
  end

  def available_study_modes_from_options
    course_options.select(&:site_still_valid).pluck(:study_mode).uniq
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

  def closed_on_apply?
    !open_on_apply
  end

  def not_available?
    !exposed_in_find
  end

  def find_url
    "https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{provider.code}/#{code}"
  end

  def in_previous_cycle
    Course.find_by(recruitment_cycle_year: recruitment_cycle_year - 1, provider_id: provider_id, code: code)
  end

  def in_next_cycle
    Course.find_by(recruitment_cycle_year: recruitment_cycle_year + 1, provider_id: provider_id, code: code)
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

  def ratifying_provider
    accredited_provider || provider
  end
end
