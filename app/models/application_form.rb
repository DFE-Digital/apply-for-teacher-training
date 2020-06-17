# The Application Form is filled in and submitted by the Candidate. Candidates
# can initially apply to 3 different courses, represented by an Application Choice.
class ApplicationForm < ApplicationRecord
  audited

  include Chased

  belongs_to :candidate
  has_many :application_choices
  has_many :application_work_experiences
  has_many :application_volunteering_experiences
  has_many :application_qualifications
  # explicit default order, so that we can preserve 'First' / 'Second' in the UI
  # as we're using numerical IDs with autonumber, 'id' is fine to achieve this
  has_many :application_references, -> { order('id ASC') }
  has_many :application_work_history_breaks

  belongs_to :previous_application_form, class_name: 'ApplicationForm', optional: true, inverse_of: 'subsequent_application_form'
  has_one :subsequent_application_form, class_name: 'ApplicationForm', foreign_key: 'previous_application_form_id', inverse_of: 'previous_application_form'

  MINIMUM_COMPLETE_REFERENCES = 2
  MAXIMUM_REFERENCES = 10
  DECISION_PENDING_STATUSES = %w[awaiting_references application_complete awaiting_provider_decision].freeze
  EQUALITY_AND_DIVERSITY_MINIMAL_ATTR = %w[sex disabilities ethnic_group].freeze

  def equality_and_diversity_answers_provided?
    answered_questions = Hash(equality_and_diversity).keys
    EQUALITY_AND_DIVERSITY_MINIMAL_ATTR.all? { |attr| attr.in? answered_questions }
  end

  enum phase: {
    apply_1: 'apply_1',
    apply_2: 'apply_2',
  }

  enum safeguarding_issues_status: {
    not_answered_yet: 'not_answered_yet',
    no_safeguarding_issues_to_declare: 'no_safeguarding_issues_to_declare',
    has_safeguarding_issues_to_declare: 'has_safeguarding_issues_to_declare',
    never_asked: 'never_asked',
  }

  before_create lambda {
    self.support_reference ||= GenerateSupportRef.call
  }

  after_save lambda {
    application_choices.update_all(updated_at: Time.zone.now)
  }

  def submitted?
    submitted_at.present?
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
    application_choices.any? && (application_choices.map(&:status) & DECISION_PENDING_STATUSES).empty?
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
    application_choices.includes(%i[course_option course]).any? do |application_choice|
      application_choice.course_option.course.primary_course?
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def blank_application?
    updated_at == created_at
  end

  def candidate_has_previously_applied?
    previous_application_form_id.present?
  end

  def candidate_can_choose_single_course?
    apply_2?
  end

  def choices_left_to_make
    number_of_choices_candidate_can_make - application_choices.size
  end

  def number_of_choices_candidate_can_make
    candidate_can_choose_single_course? ? 1 : 3
  end

  def can_add_more_choices?
    choices_left_to_make.positive?
  end

  def can_edit_after_submission?
    apply_1?
  end

  def unique_provider_list
    application_choices.includes([:provider]).map(&:provider).uniq
  end

  def ended_without_success?
    application_choices.map(&:status).all? { |status| ApplicationStateChange::UNSUCCESSFUL_END_STATES.include?(status) }
  end

  def can_add_reference?
    application_references.size < MINIMUM_COMPLETE_REFERENCES
  end

  def ready_to_be_sent_to_provider?
    !can_edit_after_submission? && enough_references_have_been_provided?
  end

  def course_choices_that_need_replacing
    (withdrawn_course_choices + full_course_choices).flatten.uniq.select(&:awaiting_references?)
  end

  def incomplete_degree_information?
    application_qualifications.degree.any?(&:incomplete_degree_information?)
  end

private

  def enough_references_have_been_provided?
    application_references.feedback_provided.count >= MINIMUM_COMPLETE_REFERENCES
  end

  def withdrawn_course_choices
    application_choices.includes(%i[provider course]).select { |choice| choice.course.withdrawn == true }
  end

  def full_course_choices
    application_choices.select { |choice| choice.course_option.no_vacancies? }
  end
end
