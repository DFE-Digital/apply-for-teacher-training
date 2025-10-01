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
           :maths_gcse, :english_gcse, :science_gcse, :adviser_status, :adviser_status_unassigned?, :applicable_degree_for_quickfire_sign_up, :applicable_degree_for_adviser, to: :application_form

  validates :email_address, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :phone_number, presence: true
  validates :country, presence: true
  validates :postcode, presence: true, unless: :international_address?
  validates :applicable_degree_for_adviser, presence: true
  validates :applicable_degree_for_quickfire_sign_up, presence: true, on: :quickfire
  validate :passed_or_retaking_gcses, unless: :international_degree?
  validate :not_yet_signed_up

  def initialize(application_form)
    @application_form = application_form
    @candidate = application_form.candidate
  end

private

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
    errors.add(:adviser_status, :already_signed_up) unless adviser_status_unassigned?
  end
end
