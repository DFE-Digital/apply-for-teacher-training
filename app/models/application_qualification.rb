class ApplicationQualification < ApplicationRecord
  include TouchApplicationChoices
  include TouchApplicationFormState

  EXPECTED_DEGREE_DATA = %i[
    qualification_type
    subject
    institution_name
    grade
    start_year
    award_year
  ].freeze

  EXPECTED_GCSE_DATA = %i[
    qualification_type
    subject
    award_year
  ].freeze

  EXPECTED_OTHER_QUALIFICATION_DATA = %i[
    qualification_type
    subject
    grade
    award_year
  ].freeze

  EXPECTED_INTERNATIONAL_OTHER_QUALIFICATION_DATA = %i[
    qualification_type
    non_uk_qualification_type
    institution_country
    award_year
  ].freeze

  # Science GCSE may have any of the following subject variants
  SCIENCE = 'science'.freeze
  SCIENCE_SINGLE_AWARD = 'science single award'.freeze
  SCIENCE_DOUBLE_AWARD = 'science double award'.freeze
  SCIENCE_TRIPLE_AWARD = 'science triple award'.freeze
  ENGLISH = 'english'.freeze
  MATHS = 'maths'.freeze
  REQUIRED_GCSE_SUBJECTS = [
    SCIENCE,
    SCIENCE_SINGLE_AWARD,
    SCIENCE_DOUBLE_AWARD,
    SCIENCE_TRIPLE_AWARD,
    ENGLISH,
    MATHS,
  ].freeze
  MAX_QUALIFICATION_TYPE_LENGTH = 256

  MAX_QUALIFICATION_GRADE_LENGTH = 256

  belongs_to :application_form, touch: true
  has_one :candidate, through: :application_form

  scope :degrees, -> { where(level: 'degree') }
  scope :gcses, -> { where(level: 'gcse') }
  scope :a_levels, -> { where(level: 'other', qualification_type: 'A level') }

  validates :qualification_type, length: { maximum: MAX_QUALIFICATION_TYPE_LENGTH }, allow_blank: true
  validates :non_uk_qualification_type, length: { maximum: MAX_QUALIFICATION_TYPE_LENGTH }, allow_blank: true
  validates :enic_reason, presence: true, on: :create

  enum enic_reason: {
    obtained: 'obtained',
    waiting: 'waiting',
    maybe: 'maybe',
    not_needed: 'not_needed',
  }, _prefix: :enic_reason, _default: :not_needed

  enum level: {
    degree: 'degree',
    gcse: 'gcse',
    other: 'other',
  }

  enum comparable_uk_degree: {
    bachelor_ordinary_degree: 'bachelor_ordinary_degree',
    bachelor_honours_degree: 'bachelor_honours_degree',
    postgraduate_certificate_or_diploma: 'postgraduate_certificate_or_diploma',
    masters_degree: 'masters_degree',
    doctor_of_philosophy: 'doctor_of_philosophy',
    post_doctoral_award: 'post_doctoral_award',
  }

  audited associated_with: :application_form

  before_save :set_public_id

  def missing_qualification?
    qualification_type == 'missing'
  end

  def incomplete_degree_information?
    return false unless degree?
    return true if predicted_grade.nil?

    return true if EXPECTED_DEGREE_DATA.any? do |field_name|
      send(field_name).blank?
    end

    false
  end

  def enic_reference=(value)
    super

    self.enic_reason = value.present? ? :obtained : :maybe
  end

  def incomplete_gcse_information?
    return false if qualification_type == 'missing' && (currently_completing_qualification == true || currently_completing_qualification == false)
    return true if grade.nil? && constituent_grades.nil?
    return true if qualification_type == 'gcse' &&
                   failed_required_gcse? &&
                   currently_completing_qualification.nil?

    return true if EXPECTED_GCSE_DATA.any? do |field_name|
      send(field_name).blank?
    end

    false
  end

  def incomplete_other_qualification?
    if qualification_type == 'non_uk'
      incomplete_international_data?
    elsif other?
      incomplete_other_qualification_data?
    else
      false
    end
  end

  def incomplete_international_data?
    EXPECTED_INTERNATIONAL_OTHER_QUALIFICATION_DATA.any? do |field_name|
      send(field_name).blank?
    end
  end

  def incomplete_other_qualification_data?
    EXPECTED_OTHER_QUALIFICATION_DATA.reject { |k| k == :grade }.any? do |field_name|
      send(field_name).blank?
    end
  end

  def enic_reference?
    if enic_reference.present?
      'Yes'
    elsif enic_reference.nil? && grade.present?
      'No'
    end
  end

  def set_grade
    case grade
    when 'n/a'
      'not_applicable'
    when 'unknown'
      'unknown'
    else
      'other'
    end
  end

  def set_other_grade
    grade if grade != 'n/a' && grade != 'unknown'
  end

  def completed?
    !predicted_grade?
  end

  def composite_equivalency_details
    details = [
      ("Enic: #{enic_reference}" if enic_reference),
      comparable_uk_qualification || comparable_uk_degree,
      equivalency_details,
    ].compact.join(' - ')

    details.strip if details.present?
  end

  GCSE_PASS_GRADES = %w[A* A B C A*A* A*A AA AB AC BB BC C* CC CD 9 8 7 6 5 4 9-9 9-8 8-8 8-7 7-7 7-6 6-6 6-5 5-5 5-4 4-4 4-3].freeze
  def failed_required_gcse?
    return true if required_gcse? && all_grades.present? && !pass_gcse?

    false
  end

  def pass_gcse?
    gcse? && all_grades.any? { |grade| GCSE_PASS_GRADES.include?(grade.upcase) }
  end

  def all_grades
    return [] unless grade.present? || constituent_grades.present?

    return [grade] if grade.present?

    constituent_grades.map { |_key, value| value['grade'] }
  end

  def required_gcse?
    gcse? &&
      qualification_type.to_s.downcase == 'gcse' &&
      REQUIRED_GCSE_SUBJECTS.include?(subject)
  end

private

  def set_public_id
    if constituent_grades.present? && subject != SCIENCE_TRIPLE_AWARD
      set_public_ids_for_constituent_grades
    elsif public_id.blank?
      self.public_id = next_available_public_id
    end
  end

  def set_public_ids_for_constituent_grades
    grades_with_ids = constituent_grades.transform_values do |grade|
      next grade if grade['public_id'].present?

      grade.merge({ public_id: next_available_public_id })
    end

    self.constituent_grades = grades_with_ids
  end

  def next_available_public_id
    ActiveRecord::Base.nextval(:qualifications_public_id_seq)
  end
end
