# The Application Form is filled in and submitted by the Candidate. Candidates
# can initially apply to 3 different courses, represented by an Application Choice.
class ApplicationForm < ApplicationRecord
  audited
  has_associated_audits
  geocoded_by :address_formatted_for_geocoding, params: { region: 'uk' }

  include Chased

  has_one :recruitment_cycle_timetable, primary_key: :recruitment_cycle_year, foreign_key: :recruitment_cycle_year
  delegate :apply_deadline_at,
           :apply_opens_at,
           :find_opens_at,
           :after_apply_deadline?,
           :before_apply_opens?,
           to: :recruitment_cycle_timetable

  belongs_to :candidate, touch: true
  has_many :application_choices
  has_many :course_options, through: :application_choices
  has_many :courses, through: :application_choices
  has_many :providers, through: :application_choices
  has_many :application_work_experiences, as: :experienceable
  has_many :application_volunteering_experiences, as: :experienceable
  has_many :application_qualifications
  has_many :degree_qualifications, -> { degrees }, class_name: 'ApplicationQualification'
  has_many :application_references
  has_many :application_work_history_breaks, as: :breakable
  has_many :emails

  belongs_to :previous_application_form, class_name: 'ApplicationForm', optional: true, inverse_of: 'subsequent_application_form'
  has_one :subsequent_application_form, class_name: 'ApplicationForm', foreign_key: 'previous_application_form_id', inverse_of: 'previous_application_form'
  has_one :english_proficiency

  has_many :application_feedback

  scope :current_cycle, -> { where(recruitment_cycle_year: RecruitmentCycleTimetable.current_year) }
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
  scope :submitted, -> { where.not(submitted_at: nil) }

  scope :rejected_and_not_accepted, lambda {
    joins(:application_choices)
      .where(application_choices: { status: :rejected })
      .where.not(
        id: ApplicationForm.joins(:application_choices).where(application_choices: { status: :offer }).select(:id),
      )
  } # Is this efficient? Test it with 100k applications

  REQUIRED_REFERENCE_SELECTIONS = 2
  REQUIRED_REFERENCES = 2
  OLD_REFERENCE_FLOW_CYCLE_YEAR = 2022

  MAXIMUM_REFERENCES = 10
  EQUALITY_AND_DIVERSITY_MINIMAL_ATTR = %w[sex disabilities ethnic_group].freeze
  BRITISH_OR_IRISH_NATIONALITIES = %w[GB IE].freeze
  MAXIMUM_NUMBER_OF_COURSE_CHOICES = 4
  MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS = 15
  RECOMMENDED_PERSONAL_STATEMENT_WORD_COUNT = 500

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
    training_with_a_disability
    volunteering
    work_history
    equality_and_diversity
  ].freeze

  CONTINUOUS_APPLICATIONS_CYCLE_YEAR = 2024

  def redact_name
    full_name.split.map do |name|
      first_letter = name.first

      name.delete!(first_letter)
      redacted = '*' * name.size

      "#{first_letter}#{redacted}"
    end.join(' ')
  end

  def equality_and_diversity_answers_provided?
    EqualityAndDiversity::ValuesChecker.new(application_form: self).check_values
  end

  enum :phase, {
    apply_1: 'apply_1',
    apply_2: 'apply_2',
  }

  enum :safeguarding_issues_status, {
    not_answered_yet: 'not_answered_yet',
    no_safeguarding_issues_to_declare: 'no_safeguarding_issues_to_declare',
    has_safeguarding_issues_to_declare: 'has_safeguarding_issues_to_declare',
    never_asked: 'never_asked',
  }

  enum :right_to_work_or_study, {
    yes: 'yes',
    no: 'no',
    decide_later: 'decide_later',
  }, prefix: true

  enum :immigration_status, {
    eu_settled: 'eu_settled',
    eu_pre_settled: 'eu_pre_settled',
    indefinite_leave_to_remain_in_the_uk: 'indefinite_leave_to_remain_in_the_uk',
    student_visa: 'student_visa',
    graduate_visa: 'graduate_visa',
    skilled_worker_visa: 'skilled_worker_visa',
    dependent_on_partners_or_parents_visa: 'dependent_on_partners_student_visa_or_dependent_on_partners_skilled_worker_visa',
    family_visa: 'family_visa',
    british_national_overseas_visa: 'british_national_overseas_visa',
    uk_ancestry_visa: 'uk_ancestry_visa',
    high_potential_individual_visa: 'high_potential_individual_visa',
    youth_mobility_scheme: 'youth_mobility_scheme',
    india_young_professionals_scheme_visa: 'india_young_professionals_scheme_visa',
    ukraine_family_scheme_or_ukraine_sponsorship_scheme_visa: 'ukraine_family_scheme_or_ukraine_sponsorship_scheme_visa',
    afghan_citizens_resettlement_scheme_or_afghan_relocations_and_assistance_policy: 'afghan_citizens_resettlement_scheme_or_afghan_relocations_and_assistance_policy',
    refugee_status: 'refugee_status',
    other: 'other',
  }

  enum :address_type, {
    uk: 'uk',
    international: 'international',
  }, suffix: :address
  attribute :address_type, :string

  enum :feedback_satisfaction_level, {
    very_satisfied: 'very_satisfied',
    satisfied: 'satisfied',
    neither_satisfied_or_dissatisfied: 'neither_satisfied_or_dissatisfied',
    dissatisfied: 'dissatisfied',
    very_dissatisfied: 'very_dissatisfied',
  }

  enum :work_history_status, {
    can_complete: 'can_complete',
    full_time_education: 'full_time_education',
    can_not_complete: 'can_not_complete',
  }

  enum :region_code, {
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

  enum :adviser_status, {
    unassigned: 'unassigned',
    waiting_to_be_assigned: 'waiting_to_be_assigned',
    assigned: 'assigned',
    previously_assigned: 'previously_assigned',
  }

  attribute :recruitment_cycle_year, :integer, default: -> { RecruitmentCycleTimetable.current_year }

  before_create :add_support_reference

  PUBLISHED_FIELDS = %w[
    first_name last_name support_reference phase submitted_at
    becoming_a_teacher interview_preferences
    date_of_birth domicile right_to_work_or_study_details
    english_main_language other_language_details
    disability_disclosure further_information safeguarding_issues_status
    address_line1 address_line2 address_line3 address_line4
    international_address country postcode equality_and_diversity
    work_history_breaks first_nationality second_nationality third_nationality
    fourth_nationality fifth_nationality phone_number immigration_status
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

    if cannot_touch_choices?
      raise 'Tried to mark an application choice from a previous cycle as changed'
    end

    application_choices.touch_all
  end

  def cannot_touch_choices?
    earlier_cycle? && prevent_unsave_touches? && !deferred?
  end

  def any_qualification_enic_reason_not_needed?
    return false if application_qualifications.empty?
    return false if application_qualifications.all? { |qualification| qualification.enic_reason.nil? }

    non_uk_qualifications = application_qualifications.reject do |qualification|
      qualification.institution_country.nil? || qualification.institution_country == 'GB' || qualification.enic_reason.nil?
    end

    non_uk_qualifications.all?(&:enic_reason_not_needed?)
  end

  def qualifications_enic_reasons_waiting_or_maybe?
    return false if application_qualifications.empty?

    application_qualifications.count do |qualification|
      qualification.enic_reason_waiting? || qualification.enic_reason_maybe?
    end >= 1
  end

  def missing_enic_reference_for_non_uk_qualifications?
    @missing_enic_reference_for_non_uk_qualifications ||= application_qualifications
                                                            .where.not(institution_country: 'GB')
                                                            .exists?(enic_reference: nil)
  end

  def submitted?
    submitted_at.present?
  end

  def unsubmitted?
    submitted_at.blank?
  end

  def defined_immigration_status?
    return false if other?

    ApplicationForm.immigration_statuses.keys.include?(immigration_status)
  end

  def awaiting_provider_decisions?
    application_choices.decision_pending.any?
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
    return false unless after_apply_deadline?

    !submitted? ||
      application_choices.blank? ||
      application_choices.map(&:status).map(&:to_sym).all? do |status|
        ApplicationStateChange::CARRY_OVER_ELIGIBLE_STATES.include?(status)
      end
  end

  def unsuccessful_and_apply_deadline_has_passed?
    ended_without_success? && after_apply_deadline?
  end

  ##########################################
  #
  # Limiting choices on applications form
  #
  ##########################################

  def maximum_number_of_choices_reached?
    application_limit_reached? || cannot_add_more_choices?
  end

  def application_limit_reached?
    application_choices.count(&:application_unsuccessful?) >= MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS
  end

  ## A slot represents the availability of one course choice

  def can_add_more_choices?
    number_of_slots_left.positive?
  end

  def can_submit_more_choices?
    number_of_in_progress_slots_left.positive?
  end

  def cannot_add_more_choices?
    number_of_slots_left.zero?
  end

  def number_of_slots_left
    MAXIMUM_NUMBER_OF_COURSE_CHOICES - number_of_slots_taken
  end

  def number_of_in_progress_slots_left
    MAXIMUM_NUMBER_OF_COURSE_CHOICES - number_of_in_progress_slots_taken
  end

  def number_of_slots_taken
    slots_taken.count
  end

  def number_of_in_progress_slots_taken
    application_choices.count(&:application_in_progress?)
  end

  def slots_taken
    application_choices.reject(&:application_unsuccessful?)
  end

  ## End Limiting choices on applications form

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

  def submitted_applications?
    application_choices.map(&:sent_to_provider_at).any?
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
    RecruitmentCycleTimetable.current_year == recruitment_cycle_year
  end

  # FIXME: This can be removed once the booleans are no longer in use.
  SECTION_COMPLETED_FIELDS.each do |section|
    define_method("#{section}_completed=") do |value|
      public_send("#{section}_completed_at=", (value ? Time.zone.now : nil))
      super(value)
    end
  end

  def v23?
    @v23 ||= recruitment_cycle_year < CONTINUOUS_APPLICATIONS_CYCLE_YEAR
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

  def no_degree_and_degree_not_completed?
    no_degrees? && !degrees_completed?
  end

  def no_degree_and_degree_completed?
    no_degrees? && degrees_completed?
  end

  def no_degrees?
    !degrees?
  end

  def degrees?
    application_qualifications.degrees.exists?
  end

  def granted_editable_extension?(section_id)
    editable_extension? && Array(editable_sections).map(&:to_sym).include?(section_id)
  end

  def editable_extension?
    editable_sections? &&
      editable_until? &&
      Time.zone.now < editable_until
  end

  def current_cycle?
    recruitment_cycle_year == RecruitmentCycleTimetable.current_year
  end

  def can_add_course_choice?
    current_cycle? && Time.zone.now.between?(find_opens_at, apply_deadline_at)
  end

  def can_submit?
    current_cycle? && Time.zone.now.between?(apply_opens_at, apply_deadline_at)
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

  def deferred?
    application_choices.pluck(:status).include?('offer_deferred')
  end

  def earlier_cycle?
    recruitment_cycle_year < RecruitmentCycleTimetable.current_year
  end

  def prevent_unsave_touches?
    !RequestStore.store[:allow_unsafe_application_choice_touches]
  end
end
