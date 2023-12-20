# The Application Form is filled in and submitted by the Candidate. Candidates
# can initially apply to 3 different courses, represented by an Application Choice.
class ApplicationForm < ApplicationRecord
  audited
  has_associated_audits
  geocoded_by :address_formatted_for_geocoding, params: { region: 'uk' }

  include Chased

  belongs_to :candidate, touch: true
  has_many :application_choices
  has_many :course_options, through: :application_choices
  has_many :courses, through: :application_choices
  has_many :providers, through: :application_choices
  has_many :application_work_experiences
  has_many :application_volunteering_experiences
  has_many :application_qualifications
  has_many :application_references
  has_many :application_work_history_breaks

  belongs_to :previous_application_form, class_name: 'ApplicationForm', optional: true, inverse_of: 'subsequent_application_form'
  has_one :subsequent_application_form, class_name: 'ApplicationForm', foreign_key: 'previous_application_form_id', inverse_of: 'previous_application_form'
  has_one :english_proficiency

  has_many :application_feedback

  scope :current_cycle, -> { where(recruitment_cycle_year: RecruitmentCycle.current_year) }
  scope :unsubmitted, -> { where(submitted_at: nil) }
  scope :inactive_since, ->(time) { where('application_forms.updated_at < ?', time) }
  scope :with_completion, ->(completion_attributes) { where(completion_attributes.map { |attr| "#{attr} = true" }.join(' AND ')) }
  scope :has_not_received_email, lambda { |mailer, mail_template|
    where(
      'NOT EXISTS (:existing_email)',
      existing_email: Email
        .select(1)
        .where('emails.application_form_id = application_forms.id')
        .where(mailer:)
        .where(mail_template:),
    )
  }
  scope :international, -> { where.not(first_nationality: %w[British Irish]) }
  scope :domestic, -> { where(first_nationality: %w[British Irish]) }

  REQUIRED_REFERENCE_SELECTIONS = 2
  REQUIRED_REFERENCES = 2
  OLD_REFERENCE_FLOW_CYCLE_YEAR = 2022

  MAXIMUM_REFERENCES = 10
  EQUALITY_AND_DIVERSITY_MINIMAL_ATTR = %w[sex disabilities ethnic_group].freeze
  BRITISH_OR_IRISH_NATIONALITIES = %w[GB IE].freeze
  MAXIMUM_NUMBER_OF_COURSE_CHOICES = 4
  MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS = 15
  RECOMMENDED_PERSONAL_STATEMENT_WORD_COUNT = 500

  # Applications created after this date include a single personal statement
  # instead of 2 personal statement sections
  SINGLE_PERSONAL_STATEMENT_FROM = DateTime.new(2023, 4, 24, 9, 0)

  BEGINNING_OF_FREE_SCHOOL_MEALS = Date.new(1964, 9, 1)
  # Free school meals were means tested from around 1980 onwards under
  # changes brought in by the Education Act 1980. Based on this, we don’t need
  # to show the question to people born before 1 September 1964 as they will have
  # turned 16 by then, and so will likely have already finished school.

  SECTION_COMPLETED_FIELDS = %w[
    becoming_a_teacher
    contact_details
    course_choices
    degrees
    efl
    english_gcse
    interview_preferences
    maths_gcse
    other_qualifications
    personal_details
    references
    safeguarding_issues
    science_gcse
    subject_knowledge
    training_with_a_disability
    volunteering
    work_history
    equality_and_diversity
  ].freeze

  CONTINUOUS_APPLICATIONS_CYCLE_YEAR = 2024

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

  enum immigration_status: {
    eu_settled: 'eu_settled',
    eu_pre_settled: 'eu_pre_settled',
    other: 'other',
  }

  enum address_type: {
    uk: 'uk',
    international: 'international',
  }, _suffix: :address
  attribute :address_type, :string

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

  enum region_code: {
    channel_islands: 'channel_islands',
    east_midlands: 'east_midlands',
    eastern: 'eastern',
    european_economic_area: 'european_economic_area',
    isle_of_man: 'isle_of_man',
    london: 'london',
    no_region: 'no_region',
    north_east: 'north_east',
    north_west: 'north_west',
    northern_ireland: 'northern_ireland',
    rest_of_the_world: 'rest_of_the_world',
    scotland: 'scotland',
    south_east: 'south_east',
    south_west: 'south_west',
    wales: 'wales',
    west_midlands: 'west_midlands',
    yorkshire_and_the_humber: 'yorkshire_and_the_humber',
  }

  enum adviser_status: {
    unassigned: 'unassigned',
    waiting_to_be_assigned: 'waiting_to_be_assigned',
    assigned: 'assigned',
    previously_assigned: 'previously_assigned',
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
    candidate.update!(candidate_api_updated_at: Time.zone.now) if form.changed.include?('phase') || created_at == updated_at
  end

  after_save do |form|
    touch_choices if form.previous_changes.keys.intersect?(PUBLISHED_FIELDS)
  end

  after_update :geocode_address_and_update_region_if_required

  def touch_choices
    return unless application_choices.any?

    if earlier_cycle? && prevent_unsave_touches? && !deferred?
      raise 'Tried to mark an application choice from a previous cycle as changed'
    end

    application_choices.touch_all
  end

  def single_personal_statement?
    created_at.nil? || created_at >= SINGLE_PERSONAL_STATEMENT_FROM
  end

  def submitted?
    submitted_at.present?
  end

  def awaiting_provider_decisions?
    application_choices.decision_pending.any?
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
      .where(level:, subject:)
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

  def all_provider_decisions_made?
    application_choices.decision_pending.none?
  end

  def science_gcse_needed?
    application_choices.includes(%i[course_option course]).any?(&:science_gcse_needed?)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def blank_application?
    updated_at == created_at
  end

  def candidate_has_previously_applied?
    previous_application_form&.submitted?
  end

  def carry_over?
    previous_recruitment_cycle? && (not_submitted_and_deadline_has_passed? || unsuccessful_and_apply_2_deadline_has_passed?)
  end

  def not_submitted_and_deadline_has_passed?
    !submitted? && ((apply_1? && CycleTimetable.apply_1_deadline_has_passed?(self)) || (apply_2? && CycleTimetable.apply_2_deadline_has_passed?(self)))
  end

  def unsuccessful_and_apply_2_deadline_has_passed?
    ended_without_success? && CycleTimetable.apply_2_deadline_has_passed?(self)
  end

  def choices_left_to_make
    number_of_choices_candidate_can_make - available_application_choices
  end

  def number_of_choices_candidate_can_make
    MAXIMUM_NUMBER_OF_COURSE_CHOICES
  end

  def available_application_choices
    continuous_applications? ? application_choices.size - count_unsuccessful_choices : application_choices.size
  end

  def count_unsuccessful_choices(count_inactive: true)
    application_choices.count { |choice| (count_inactive || choice.status.to_sym != :inactive) && ApplicationStateChange::UNSUCCESSFUL_STATES.include?(choice.status.to_sym) }
  end

  def reached_maximum_unsuccessful_choices?
    count_unsuccessful_choices(count_inactive: false) >= MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS
  end

  def can_submit_further_applications?
    count_of_in_progress_applications < MAXIMUM_NUMBER_OF_COURSE_CHOICES
  end

  def count_of_in_progress_applications
    application_choices.count { |choice| ApplicationStateChange::IN_PROGRESS_STATES.include?(choice.status.to_sym) }
  end

  def can_add_more_choices?
    choices_left_to_make.positive?
  end

  def recruited?
    application_choices.recruited.any?
  end

  def successful?
    application_choices.present? &&
      application_choices.map(&:status).map(&:to_sym).any? { |status| ApplicationStateChange::SUCCESSFUL_STATES.include?(status) }
  end

  def any_offer_accepted?
    application_choices.present? &&
      application_choices.map(&:status).map(&:to_sym).any? { |status| (ApplicationStateChange::ACCEPTED_STATES - [:conditions_not_met]).include?(status) }
  end

  def ended_without_success?
    application_choices.present? &&
      application_choices.map(&:status).map(&:to_sym).all? { |status| ApplicationStateChange::UNSUCCESSFUL_STATES.include?(status) }
  end

  def provider_decision_made?
    application_choices.present? &&
      application_choices.map(&:status).map(&:to_sym).all? { |status| (ApplicationStateChange::SUCCESSFUL_STATES + ApplicationStateChange::UNSUCCESSFUL_STATES).include?(status) }
  end

  def incomplete_degree_information?
    application_qualifications.degree.any?(&:incomplete_degree_information?)
  end

  def complete_references_information?
    application_references.count >= REQUIRED_REFERENCES
  end

  def british_or_irish?
    nationality_codes = nationalities.map { |n| NATIONALITIES_BY_NAME[n] }.compact

    nationality_codes.any? do |code|
      code.in? BRITISH_OR_IRISH_NATIONALITIES
    end
  end

  def international_applicant?
    nationalities.present? && !british_or_irish?
  end

  RESTRUCTURED_IMMIGRATION_STATUS_STARTS = 2022
  def restructured_immigration_status?
    recruitment_cycle_year >= RESTRUCTURED_IMMIGRATION_STATUS_STARTS
  end

  def build_nationalities_hash
    CandidateInterface::GetNationalitiesFormHash.new(application_form: self).call
  end

  def nationalities
    [first_nationality, second_nationality, third_nationality, fourth_nationality, fifth_nationality].compact
  end

  def full_address
    if international_address?
      [
        address_line1,
        address_line2,
        address_line3,
        address_line4,
        COUNTRIES_AND_TERRITORIES[country],
      ].compact_blank
    else
      [
        address_line1,
        address_line2,
        address_line3,
        address_line4,
        postcode,
      ].compact_blank
    end
  end

  def maximum_number_of_course_choices?
    if continuous_applications?
      applications_left.zero?
    else
      application_choices.count >= maximum_number_of_course_choices
    end
  end

  def applications_left
    maximum_number_of_course_choices - number_of_in_progress_applications
  end

  def number_of_in_progress_applications
    in_progress_applications.count
  end

  def in_progress_applications
    application_choices.reject(&:application_unsuccessful?)
  end

  def submitted_applications?
    application_choices.map(&:sent_to_provider_at).any?
  end

  def support_cannot_add_course_choice?
    number_of_unsuccessful_application_choices >= maximum_number_of_course_choices
  end

  def number_of_unsuccessful_application_choices
    application_choices.where.not(status: ApplicationStateChange::UNSUCCESSFUL_STATES).count
  end

  def maximum_number_of_course_choices
    MAXIMUM_NUMBER_OF_COURSE_CHOICES
  end

  def editable?
    subsequent_application_form.blank?
  end

  def contains_course?(course)
    application_choices
      .joins(:course_option)
      .not_reappliable
      .exists?(course_options: { course_id: course.id })
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
      return true if british_or_irish?
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

  def selected_enough_references?
    # For the purposes of this method, we only care that we have at least the
    # minimum selected. Other parts of the system will enforce having no more
    # than the minimum selected.
    selected_references.count >= REQUIRED_REFERENCE_SELECTIONS
  end

  def selected_incorrect_number_of_references?
    selected_references.count != REQUIRED_REFERENCE_SELECTIONS
  end

  def selected_references
    application_references.selected
  end

  def minimum_references_available_for_selection?
    application_references.feedback_provided.count >= REQUIRED_REFERENCE_SELECTIONS
  end

  def address_formatted_for_geocoding
    full_address.compact.join(', ')
  end

  def domicile
    if international_address?
      DomicileResolver.hesa_code_for_country country
    else
      DomicileResolver.hesa_code_for_postcode postcode
    end
  end

  def mark_sections_incomplete_if_review_needed!
    if reviewable?(:becoming_a_teacher)
      update!(becoming_a_teacher_completed: nil)
    end

    if reviewable?(:subject_knowledge)
      update!(subject_knowledge_completed: nil)
    end
  end

  def rejection_reasons(section)
    CandidateInterface::RejectionReasonsHistory.all_previous_applications(self, section)
  end

  def previous_application_rejection_reason(section)
    CandidateInterface::RejectionReasonsHistory.previous_application(self, section)
  end

  def review_pending?(section)
    !send("#{section}_completed?") && reviewable?(section)
  end

  def reviewable?(section)
    apply_2? && previous_application_rejection_reason(section).present?
  end

  def self.with_unsafe_application_choice_touches
    prior_state = RequestStore.store[:allow_unsafe_application_choice_touches].presence || false

    RequestStore.store[:allow_unsafe_application_choice_touches] = true
    return_value = yield
    RequestStore.store[:allow_unsafe_application_choice_touches] = prior_state

    return_value
  end

  def qualifications_completed?
    degrees_completed &&
      maths_gcse_completed &&
      english_gcse_completed &&
      (!science_gcse_needed? || science_gcse_completed)
  end

  def ask_about_free_school_meals?
    british_or_irish? && date_of_birth >= BEGINNING_OF_FREE_SCHOOL_MEALS
  end

  def current_recruitment_cycle?
    RecruitmentCycle.current_year == recruitment_cycle_year
  end

  # FIXME: This can be removed once the booleans are no longer in use.
  SECTION_COMPLETED_FIELDS.each do |section|
    define_method("#{section}_completed=") do |value|
      public_send("#{section}_completed_at=", (value ? Time.zone.now : nil))
      super(value)
    end
  end

  def single_personal_statement_application?
    FeatureFlag.active?(:one_personal_statement) && single_personal_statement?
  end

  def continuous_applications?
    @continuous_applications ||= recruitment_cycle_year >= CONTINUOUS_APPLICATIONS_CYCLE_YEAR
  end

  module ColumnSectionMapping
    def by_column(*column_names)
      mapping = ActiveSupport::HashWithIndifferentAccess.new({
        # Personal information
        'date_of_birth' => 'personal_information',
        'first_name' => 'personal_information',
        'last_name' => 'personal_information',

        # Contact Information
        'phone_number' => 'contact_information',
        'address_line1' => 'contact_information',
        'address_line2' => 'contact_information',
        'address_line3' => 'contact_information',
        'address_line4' => 'contact_information',
        'country' => 'contact_information',
        'postcode' => 'contact_information',
        'region_code' => 'contact_information',

        # Interview Preferences
        'interview_preferences' => 'interview_preferences',

        # Disability
        'disability_disclosure' => 'disability_disclosure',
      })

      return mapping[column_names.first] if column_names.length == 1

      Array(column_names).each_with_object([]) do |column_name, set|
        set << mapping[column_name]
      end.uniq
    end

    def by_section(*sections)
      mapping = ActiveSupport::HashWithIndifferentAccess.new({
        # Personal information
        'personal_information' => %w[
          date_of_birth
          first_name
          last_name
        ],

        # Contact Information
        'contact_information' => %w[
          phone_number
          address_line1
          address_line2
          address_line3
          address_line4
          country
          postcode
          region_code
        ],

        # Interview Preferences
        'interview_preferences' => ['interview_preferences'],

        # Disability
        'disability_disclosure' => ['disability_disclosure'],
      })

      Array(sections).flat_map do |section|
        mapping[section]
      end.compact
    end
    module_function :by_column, :by_section
  end

  def granted_editable_extension?(section_id)
    editable_extension? && Array(editable_sections).map(&:to_sym).include?(section_id)
  end

  def editable_extension?
    editable_sections? &&
      editable_until? &&
      Time.zone.now < editable_until
  end

private

  def geocode_address_and_update_region_if_required
    return unless address_changed?

    if international_address?
      update!(
        latitude: nil,
        longitude: nil,
        region_code: find_international_region_from_country,
      )
    else
      GeocodeApplicationAddressWorker.perform_in(5.seconds, id)
      LookupAreaByPostcodeWorker.perform_in(10.seconds, id)
    end
  end

  def find_international_region_from_country
    if EU_EEA_SWISS_COUNTRY_CODES.include?(country)
      :european_economic_area
    else
      :rest_of_the_world
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

  def add_support_reference
    return if support_reference

    loop do
      self.support_reference = GenerateSupportReference.call
      break unless ApplicationForm.exists?(support_reference:)
    end
  end

  def previous_recruitment_cycle?
    RecruitmentCycle.current_year >= recruitment_cycle_year
  end

  def deferred?
    application_choices.pluck(:status).include?('offer_deferred')
  end

  def earlier_cycle?
    recruitment_cycle_year < RecruitmentCycle.current_year
  end

  def prevent_unsave_touches?
    !RequestStore.store[:allow_unsafe_application_choice_touches]
  end
end
