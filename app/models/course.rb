class Course < ApplicationRecord
  belongs_to :provider
  has_many :course_options
  has_many :application_choices, through: :course_options
  belongs_to :accredited_provider, class_name: 'Provider', optional: true

  audited associated_with: :provider

  validates :level, presence: true
  validates :code, uniqueness: { scope: :provider_id }

  scope :open_on_apply, -> { exposed_in_find.where(open_on_apply: true) }
  scope :exposed_in_find, -> { where(exposed_in_find: true) }

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

  def name_and_description
    "#{name} #{description}"
  end

  def name_and_provider
    "#{name} #{accredited_provider&.name}"
  end

  def name_provider_and_description
    "#{name} #{accredited_provider&.name} #{description}"
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

  def both_study_modes_available?
    study_mode == 'full_time_or_part_time'
  end

  def full?
    course_options.all?(&:no_vacancies?)
  end

  def find_url
    "https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{provider.code}/#{code}"
  end

  def application_forms
    ApplicationForm
      .includes(:candidate, :application_choices)
      .joins(application_choices: :course_option)
      .where(application_choices: { course_options: { course: self } })
      .distinct
  end
end
