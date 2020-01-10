# The Application Form is filled in and submitted by the Candidate. Candidates
# can initially apply to 3 different courses, represented by an Application Choice.
class ApplicationForm < ApplicationRecord
  belongs_to :candidate
  has_many :application_choices
  has_many :application_work_experiences
  has_many :application_volunteering_experiences
  has_many :application_qualifications
  # explicit default order, so that we can preserve 'First' / 'Second' in the UI
  # as we're using numerical IDs with autonumber, 'id' is fine to achieve this
  has_many :application_references, -> { order('id ASC') }

  MINIMUM_COMPLETE_REFERENCES = 2
  validates_length_of :application_references, maximum: MINIMUM_COMPLETE_REFERENCES

  enum phase: {
    apply_1: 'apply_1',
    apply_2: 'apply_2',
  }

  before_create -> {
    self.support_reference ||= GenerateSupportRef.call
  }

  after_save -> {
    application_choices.update_all(updated_at: Time.zone.now)
  }

  def submitted?
    submitted_at.present?
  end

  def application_references_complete?
    application_references.feedback_provided.count == MINIMUM_COMPLETE_REFERENCES
  end

  def awaiting_provider_decisions?
    application_choices.where(status: :awaiting_provider_decision).any?
  end

  def qualification_in_subject(level, subject)
    application_qualifications
      .where(level: level, subject: subject)
      .order(created_at: 'asc')
      .first
  end

  def first_not_declined_application_choice
    application_choices
      .where.not(decline_by_default_at: nil)
      .first
  end

  def maths_gcse
    qualification_in_subject(:gcse, :maths)
  end

  def english_gcse
    qualification_in_subject(:gcse, :english)
  end

  def science_gcse
    qualification_in_subject(:gcse, :science)
  end

  def any_enrolled?
    application_choices.map.any?(&:enrolled?)
  end

  def any_recruited?
    application_choices.map.any?(&:recruited?)
  end

  def any_accepted_offer?
    application_choices.map.any?(&:pending_conditions?)
  end

  def all_provider_decisions_made?
    application_choices.any? && application_choices.where(status: %w[awaiting_references application_complete awaiting_provider_decision]).empty?
  end

  def all_choices_withdrawn?
    application_choices.any? &&
      application_choices.all? { |application_choice| application_choice.status == 'withdrawn' }
  end

  def any_awaiting_provider_decision?
    application_choices.map.any?(&:awaiting_provider_decision?)
  end

  def any_offers?
    application_choices.map.any?(&:offer?)
  end

  def science_gcse_needed?
    return true unless FeatureFlag.active?('conditional_science_gcse')

    application_choices.any? do |application_choice|
      application_choice.course_option.course.primary_course?
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def amendable?
    FeatureFlag.active?('edit_application') && submitted? && within_amend_period?
  end

  def within_amend_period?
    application_choices.none?(&:edit_by_expired?)
  end

  audited
end
