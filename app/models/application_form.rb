# The Application Form is filled in and submitted by the Candidate. Candidates
# can initially apply to 3 different courses, represented by an Application Choice.
class ApplicationForm < ApplicationRecord
  audited
  has_associated_audits
  geocoded_by :address_formatted_for_geocoding, params: { region: 'uk' }

  include Chased

  belongs_to :candidate, touch: true
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
  has_one :english_proficiency

  has_many :application_feedback

  scope :current_cycle, -> { where(recruitment_cycle_year: RecruitmentCycle.current_year) }

  MINIMUM_COMPLETE_REFERENCES = 2
  MAXIMUM_REFERENCES = 10
  EQUALITY_AND_DIVERSITY_MINIMAL_ATTR = %w[sex disabilities ethnic_group].freeze
  ENGLISH_SPEAKING_NATIONALITIES = %w[GB IE].freeze
  MAXIMUM_PHASE_ONE_COURSE_CHOICES = 3
  MAXIMUM_PHASE_TWO_COURSE_CHOICES = 1

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

  enum right_to_work_or_study: {
    yes: 'yes',
    no: 'no',
    decide_later: 'decide_later',
  }, _prefix: true

  enum address_type: {
    uk: 'uk',
    international: 'international',
  }
  attribute :address_type, :string, default: 'uk'

  enum feedback_satisfaction_level: {
    very_satisfied: 'very_satisfied',
    satisfied: 'satisfied',
    neither_satisfied_or_dissatisfied: 'neither_satisfied_or_dissatisfied',
    dissatisfied: 'dissatisfied',
    very_dissatisfied: 'very_dissatisfied',
  }

  enum work_history_status: {
    can_complete: 'can_complete',
    full_time_education: 'full_time_education',
    can_not_complete: 'can_not_complete',
  }

  attribute :recruitment_cycle_year, :integer, default: -> { RecruitmentCycle.current_year }

  before_create :add_support_reference

  PUBLISHED_FIELDS = %w[
    first_name last_name support_reference phase submitted_at
    becoming_a_teacher subject_knowledge interview_preferences
    date_of_birth domicile right_to_work_or_study_details
    english_main_language other_language_details
    disability_disclosure further_information safeguarding_issues_status
    address_line1 address_line2 address_line3 address_line4
    international_address country postcode equality_and_diversity
    work_history_breaks first_nationality second_nationality third_nationality
    fourth_nationality fifth_nationality phone_number
  ].freeze

  before_save do |form|
    if (form.changed & PUBLISHED_FIELDS).any?
      application_choices.touch_all
    end
  end

  after_commit :geocode_address_if_required

  def submitted?
    submitted_at.present?
  end

  def awaiting_provider_decisions?
    application_choices.where(status: :awaiting_provider_decision).any?
  end

  def first_not_declined_application_choice
    application_choices
      .where.not(decline_by_default_at: nil)
      .first
  end

  def qualification_in_subject(level, subject)
    if subject.to_s == ApplicationQualification::SCIENCE
      # A Science GCSE may have any one of the following subject variants
      subject = [
        ApplicationQualification::SCIENCE,
        ApplicationQualification::SCIENCE_SINGLE_AWARD,
        ApplicationQualification::SCIENCE_DOUBLE_AWARD,
        ApplicationQualification::SCIENCE_TRIPLE_AWARD,
      ]
    end

    application_qualifications
      .where(level: level, subject: subject)
      .order(created_at: 'asc')
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

  def any_recruited?
    application_choices.map.any?(&:recruited?)
  end

  def any_deferred?
    application_choices.map.any?(&:offer_deferred?)
  end

  def any_accepted_offer?
    application_choices.map.any?(&:pending_conditions?)
  end

  def all_provider_decisions_made?
    application_choices.any? && (application_choices.map(&:status).map(&:to_sym) & ApplicationStateChange::DECISION_PENDING_STATUSES).empty?
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

  def all_applications_not_sent?
    application_choices.any?(&:application_not_sent?) &&
      application_choices.all? do |application_choice|
        application_choice.application_not_sent? || application_choice.withdrawn?
      end
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

  def must_be_carried_over?
    if ended_without_success?
      recruitment_cycle_year < RecruitmentCycle.current_year || EndOfCycleTimetable.between_cycles_apply_2?
    elsif !submitted?
      recruitment_cycle_year < RecruitmentCycle.current_year && !EndOfCycleTimetable.between_cycles_apply_1?
    end
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
    application_choices.present? &&
      application_choices.map(&:status).map(&:to_sym).all? { |status| ApplicationStateChange::UNSUCCESSFUL_END_STATES.include?(status) }
  end

  def ended_with_success?
    application_choices.present? &&
      application_choices.map(&:status).map(&:to_sym).all? { |status| ApplicationStateChange::ACCEPTED_STATES.include?(status) }
  end

  def can_add_reference?
    application_references.size < MINIMUM_COMPLETE_REFERENCES
  end

  def too_many_complete_references?
    application_references.feedback_provided.size > MINIMUM_COMPLETE_REFERENCES
  end

  def ready_to_be_sent_to_provider?
    !can_edit_after_submission? && enough_references_have_been_provided?
  end

  def incomplete_degree_information?
    application_qualifications.degree.any?(&:incomplete_degree_information?)
  end

  def english_speaking_nationality?
    nationality_codes = nationalities.map { |n| NATIONALITIES_BY_NAME[n] }.compact

    nationality_codes.any? do |code|
      code.in? ENGLISH_SPEAKING_NATIONALITIES
    end
  end

  def efl_section_required?
    nationalities.present? && !english_speaking_nationality?
  end

  def build_nationalities_hash
    CandidateInterface::GetNationalitiesFormHash.new(application_form: self).call
  end

  def nationalities
    [first_nationality, second_nationality, third_nationality, fourth_nationality, fifth_nationality].reject(&:nil?)
  end

  def full_address
    if international?
      [
        address_line1,
        address_line2,
        address_line3,
        address_line4,
        COUNTRIES[country],
      ].reject(&:blank?)
    else
      [
        address_line1,
        address_line2,
        address_line3,
        address_line4,
        postcode,
      ].reject(&:blank?)
    end
  end

  def has_the_maximum_number_of_course_choices?
    application_choices.count >= maximum_number_of_course_choices
  end

  def support_cannot_add_course_choice?
    application_choices.where.not(status: :withdrawn).count >= maximum_number_of_course_choices
  end

  def maximum_number_of_course_choices
    if apply_1?
      MAXIMUM_PHASE_ONE_COURSE_CHOICES
    else
      MAXIMUM_PHASE_TWO_COURSE_CHOICES
    end
  end

  def contains_course?(course)
    potential_course_option_ids = CourseOption.where(course_id: course.id).map(&:id)
    current_course_option_ids = application_choices.map(&:course_option_id)

    (potential_course_option_ids & current_course_option_ids).present?
  end

  # The `english_main_language` and `english_language_details` database fields
  # are deprecated. This arose from the 'Personal Details > Languages' page
  # being replaced by an 'English as a Foreign Language' section. The fields
  # are only editable on applications that already contain user-submitted
  # values for them, and otherwise remain nil. Because we need to continue
  # sending these values in the current version of the Vendor API, we override
  # the default ORM methods. In both cases we use the contents of the legacy
  # database field if present, otherwise we attempt to infer values from other
  # parts of the application.
  def english_main_language(fetch_database_value: false)
    return self[:english_main_language] if fetch_database_value

    if self[:english_main_language].nil?
      return true if english_speaking_nationality?
      return true if english_proficiency&.qualification_not_needed?

      false
    else
      self[:english_main_language]
    end
  end

  def english_language_details
    self[:english_language_details].presence || english_proficiency&.formatted_qualification_description
  end

  def english_language_qualification_details
    english_proficiency&.formatted_qualification_description.presence || self[:english_language_details]
  end

  def has_rejection_reason?
    application_choices.any? { |application_choice| application_choice.rejection_reason? || application_choice.offer_withdrawal_reason }
  end

  def references_did_not_come_back_in_time?
    application_references.any?(&:cancelled_at_end_of_cycle?)
  end

  def enough_references_have_been_provided?
    application_references.feedback_provided.count >= MINIMUM_COMPLETE_REFERENCES
  end

  def address_formatted_for_geocoding
    full_address.compact.join(', ')
  end

  def domicile
    if international?
      DomicileResolver.hesa_code_for_country country
    else
      DomicileResolver.hesa_code_for_postcode postcode
    end
  end

private

  def geocode_address_if_required
    return unless address_changed?

    if international?
      update!(latitude: nil, longitude: nil)
    else
      GeocodeApplicationAddressWorker.perform_async(id)
    end
  end

  def address_changed?
    saved_change_to_address_line1? ||
      saved_change_to_address_line2? ||
      saved_change_to_address_line3? ||
      saved_change_to_address_line4? ||
      saved_change_to_country? ||
      saved_change_to_postcode? ||
      saved_change_to_address_type?
  end

  def withdrawn_course_choices
    application_choices.includes(%i[provider course]).select { |choice| choice.course.withdrawn == true }
  end

  def full_course_choices
    application_choices.includes(%i[course_option]).select { |choice| choice.course_option.no_vacancies? }
  end

  def courses_not_on_apply
    application_choices.includes(%i[course]).reject { |choice| choice.course.open_on_apply }
  end

  def add_support_reference
    return if support_reference

    loop do
      self.support_reference = GenerateSupportReference.call
      break unless ApplicationForm.exists?(support_reference: support_reference)
    end
  end
end
