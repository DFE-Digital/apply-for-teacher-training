class Adviser::ApplicationFormValidations
  include ActiveModel::Model

  APPLICABLE_DOMESTIC_DEGREE_GRADES = [
    'First-class honours',
    'Upper second-class honours (2:1)',
    'Lower second-class honours (2:2)',
  ].freeze
  APPLICABLE_DOMESTIC_DEGREE_LEVELS = %w[bachelor master doctor].freeze
  APPLICABLE_INTERNATIONAL_DEGREE_LEVELS = %w[
    bachelor_honours_degree
    postgraduate_certificate_or_diploma
    masters_degree
    doctor_of_philosophy
    post_doctoral_award
  ].freeze

  attr_reader :application_form, :candidate

  delegate :email_address, to: :candidate
  delegate :id, :first_name, :last_name, :date_of_birth, :phone_number, :country, :postcode, :international_address?,
           :maths_gcse, :english_gcse, :science_gcse, :adviser_status, :unassigned?, to: :application_form

  validates :email_address, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :phone_number, presence: true
  validates :country, presence: true
  validates :postcode, presence: true, unless: :international_address?
  validates :applicable_degree_for_adviser, presence: true
  validate :passed_or_retaking_gcses, unless: :international_degree?
  validate :not_yet_signed_up

  def initialize(application_form)
    @application_form = application_form
    @candidate = application_form.candidate
  end

  def applicable_degree_for_adviser
    @applicable_degree ||= application_form.application_qualifications
      .degrees
      .reject(&:incomplete_degree_information?)
      .reject(&method(:international_without_equivalency?))
      .select(&method(:applicable_degree_grade?))
      .select(&method(:applicable_degree_level?))
      .min_by(&method(:highest_grade_first))
  end

private

  def international_without_equivalency?(degree)
    degree.international? && !degree.enic_reference
  end

  def applicable_degree_level?(degree)
    if degree.international?
      degree.comparable_uk_degree.in?(APPLICABLE_INTERNATIONAL_DEGREE_LEVELS)
    else
      degree.qualification_level.in?(APPLICABLE_DOMESTIC_DEGREE_LEVELS)
    end
  end

  def applicable_degree_grade?(degree)
    degree.international? || degree.grade.in?(APPLICABLE_DOMESTIC_DEGREE_GRADES)
  end

  def highest_grade_first(degree)
    APPLICABLE_DOMESTIC_DEGREE_GRADES.index(degree.grade) || (APPLICABLE_DOMESTIC_DEGREE_GRADES.count + 1)
  end

  def international_degree?
    applicable_degree_for_adviser&.international?
  end

  def passed_or_retaking_gcses
    check_for_gcse(:maths_gcse)
    check_for_gcse(:english_gcse)
  end

  def check_for_gcse(gcse_key)
    gcse = send(gcse_key)
    passed_or_retaking_gcses = gcse&.pass_gcse? || gcse&.currently_completing_qualification?
    errors.add(gcse_key, :must_have_passed_or_be_retaking) unless passed_or_retaking_gcses
  end

  def not_yet_signed_up
    errors.add(:adviser_status, :already_signed_up) unless unassigned?
  end
end
