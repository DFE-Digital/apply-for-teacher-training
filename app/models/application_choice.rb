class ApplicationChoice < ApplicationRecord
  include Chased
  include TouchApplicationFormState

  self.ignored_columns += %w[decline_by_default_at decline_by_default_days]

  before_create :set_initial_status

  belongs_to :application_form, touch: true
  has_one :candidate, through: :application_form

  belongs_to :course_option
  has_one :site, through: :course_option
  has_one :course, through: :course_option
  has_one :provider, through: :course
  has_one :accredited_provider, through: :course, class_name: 'Provider'

  belongs_to :original_course_option, class_name: 'CourseOption', optional: true

  belongs_to :current_course_option, class_name: 'CourseOption'
  has_one :current_site, through: :current_course_option, source: :site
  has_one :current_course, through: :current_course_option, source: :course
  has_one :current_provider, through: :current_course, source: :provider
  has_one :current_accredited_provider, through: :current_course, source: :accredited_provider
  has_one :offer

  has_many :notes, dependent: :destroy
  has_many :interviews, dependent: :destroy
  has_many :withdrawal_reasons, dependent: :destroy
  has_many :draft_withdrawal_reasons, -> { draft }, class_name: 'WithdrawalReason', dependent: :destroy
  has_many :published_withdrawal_reasons, -> { published }, class_name: 'WithdrawalReason', dependent: :destroy

  has_many :work_experiences, as: :experienceable, class_name: 'ApplicationWorkExperience'
  has_many :volunteering_experiences, as: :experienceable, class_name: 'ApplicationVolunteeringExperience'
  has_many :work_history_breaks, as: :breakable, class_name: 'ApplicationWorkHistoryBreak'

  validates_with ReapplyValidator, reappliable: true

  has_associated_audits
  audited associated_with: :application_form

  # Note that prior to October 2020, we used to have awaiting_references and
  # application_complete statuses. These will still show up in older audit logs.
  enum :status, {
    unsubmitted: 'unsubmitted',
    cancelled: 'cancelled',
    awaiting_provider_decision: 'awaiting_provider_decision',
    inactive: 'inactive',
    interviewing: 'interviewing',
    offer: 'offer',
    pending_conditions: 'pending_conditions',
    recruited: 'recruited',
    rejected: 'rejected',
    application_not_sent: 'application_not_sent',
    offer_withdrawn: 'offer_withdrawn',
    declined: 'declined',
    withdrawn: 'withdrawn',
    conditions_not_met: 'conditions_not_met',
    offer_deferred: 'offer_deferred',
  }

  # Different formats for rejection reasons data.
  # See https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/docs/app_concepts/reasons-for-rejection.md
  enum :rejection_reasons_type, {
    rejection_reason: 'rejection_reason',           # Single text field reason predating Structured Reasons For Rejection and still writeable via API.
    reasons_for_rejection: 'reasons_for_rejection', # Initial iteration of Structured Reasons For Rejection model.
    rejection_reasons: 'rejection_reasons',         # Current iteration of Structured Reasons For Rejection.
    vendor_api_rejection_reasons: 'vendor_api_rejection_reasons', # Rejection reasons via the Vendor API.
  }, prefix: :rejection_reasons_type

  scope :visible_to_provider, -> { where(status: ApplicationStateChange.states_visible_to_provider) }
  scope :reappliable, -> { where(status: ApplicationStateChange.reapply_states) }
  scope :not_reappliable, -> { where(status: ApplicationStateChange.non_reapply_states) }
  scope :decision_pending, -> { where(status: ApplicationStateChange::DECISION_PENDING_STATUSES) }
  scope :decision_pending_and_inactive, -> { where(status: ApplicationStateChange::DECISION_PENDING_AND_INACTIVE_STATUSES) }
  scope :accepted, -> { where(status: ApplicationStateChange::ACCEPTED_STATES) }
  scope :inactive_past_day, -> { inactive.where(inactive_at: 1.day.ago..Time.zone.now) }

  def application_work_experiences
    return application_form.application_work_experiences if work_experiences.blank?

    work_experiences
  end

  def application_volunteering_experiences
    return application_form.application_volunteering_experiences if volunteering_experiences.blank?

    volunteering_experiences
  end

  def application_work_history_breaks
    return application_form.application_work_history_breaks if work_history_breaks.blank?

    work_history_breaks
  end

  def submitted?
    !unsubmitted?
  end

  def decision_pending?
    ApplicationStateChange::DECISION_PENDING_AND_INACTIVE_STATUSES.include? status.to_sym
  end

  def pre_offer?
    ApplicationStateChange::OFFERED_STATES.exclude? status.to_sym
  end

  def application_in_progress?
    ApplicationStateChange::IN_PROGRESS_STATES.include? status.to_sym
  end

  def self.in_progress
    where(status: ApplicationStateChange::IN_PROGRESS_STATES)
  end

  def application_unsuccessful?
    ApplicationStateChange::UNSUCCESSFUL_STATES.include? status.to_sym
  end

  def application_unsuccessful_without_inactive?
    (ApplicationStateChange::UNSUCCESSFUL_STATES - %i[inactive]).include? status.to_sym
  end

  def accepted_choice?
    ApplicationStateChange::ACCEPTED_STATES.include? status.to_sym
  end

  def different_offer?
    current_course_option_id && current_course_option_id != course_option_id
  end

  def recruitment_cycle
    current_course.recruitment_cycle_year
  end

  delegate :course_not_available?, to: :course_option
  delegate :withdrawn?, to: :course, prefix: true
  delegate :submitted_at, to: :application_form, allow_nil: true, prefix: true

  def course_not_available_error
    I18n.t('errors.application_choices.course_not_available', descriptor: course.provider_and_name_code)
  end

  delegate :course_application_status_closed?, to: :course_option

  def course_application_status_closed
    I18n.t(
      'errors.application_choices.course_application_status_closed',
      course_name_and_code: course.name_and_code,
      provider_name: course.provider.name,
    )
  end

  delegate :full?, :available?, to: :course, prefix: true

  def course_full_error
    I18n.t('errors.application_choices.course_full', descriptor: course.provider_and_name_code)
  end

  def site_full?
    course.course_options.where(site: course_option.site).vacancies.blank?
  end

  def site_full_error
    I18n.t('errors.application_choices.site_full', descriptor: course.provider_and_name_code)
  end

  def site_invalid?
    !course_option.site_still_valid
  end

  def site_invalid_error
    I18n.t('errors.application_choices.site_invalid', descriptor: course.provider_and_name_code)
  end

  def study_mode_full?
    course_option.no_vacancies?
  end

  def study_mode_full_error
    I18n.t(
      'errors.application_choices.study_mode_full',
      descriptor: course.provider_and_name_code,
      study_mode: course_option.study_mode.humanize.downcase,
    )
  end

  def course_option_availability_error?
    [
      course_not_available?,
      course_application_status_closed?,
      course_full?,
      site_full?,
      study_mode_full?,
      !course.open_for_applications?,
    ].any?
  end

  def self_and_siblings
    application_form.application_choices
  end

  def no_feedback?
    rejection_reason.blank? && structured_rejection_reasons.blank?
  end

  def display_provider_feedback?
    (rejected? && (rejection_reason.present? || structured_rejection_reasons.present?)) ||
      (offer_withdrawn? && offer_withdrawal_reason.present?)
  end

  def associated_providers
    [provider, accredited_provider].compact.uniq
  end

  def unconditional_offer?
    offer&.unconditional?
  end

  def all_conditions_met?
    offer.conditions.all?(&:met?)
  end

  def unconditional_offer_pending_recruitment?
    return false unless recruited?

    unconditional_offer?
  end

  def withdrawn_at_candidates_request?
    (declined? || withdrawn?) && Audited::Audit.exists?(
      user_type: 'ProviderUser',
      auditable: self,
      comment: [
        I18n.t('transient_application_states.withdrawn_at_candidates_request.declined.audit_comment'),
        I18n.t('transient_application_states.withdrawn_at_candidates_request.withdrawn.audit_comment'),
      ],
    )
  end

  def configure_initial_course_choice!(course_option)
    self.original_course_option = course_option
    self.course_option = course_option

    update_course_option_and_associated_fields!(
      course_option,
      other_fields: {
        original_course_option: course_option,
        course_option:,
      },
    )
  end

  def update_course_option_and_associated_fields!(new_course_option, other_fields: {}, audit_comment: nil)
    attrs = {
      current_course_option: new_course_option,
      current_recruitment_cycle_year: new_course_option.course.recruitment_cycle_year,
      personal_statement: application_form.becoming_a_teacher,
    }.merge(other_fields)
    attrs[:audit_comment] = audit_comment if audit_comment.present?

    assign_attributes(attrs) # provider_ids_for_access needs this to be set beforehand
    self.provider_ids = provider_ids_for_access

    update!(attrs)
  end

  def provider_ids_for_access
    [
      course_option.course.provider.id,
      course_option.course.accredited_provider&.id,
      current_course_option.course.provider.id,
      current_course_option.course.accredited_provider&.id,
    ].compact.uniq
  end

  def science_gcse_needed?
    course.primary_course?
  end

  def supplementary_statuses
    [].tap do |supplementary_statuses|
      if recruited? && RecruitedWithPendingConditions.new(application_choice: self).call
        supplementary_statuses << :ske_pending_conditions
      end
    end
  end

  def updated_recently_since_submitted?
    RecentlyUpdatedApplicationChoice.new(application_choice: self).call
  end

  def days_since_sent_to_provider
    days_since_calculation(sent_to_provider_at)
  end

  def days_since_offered
    days_since_calculation(offered_at)
  end

  delegate :teacher_degree_apprenticeship?, :undergraduate?, to: :current_course

  def undergraduate_course_and_application_form_with_degree?
    undergraduate? && application_form.degrees?
  end

private

  def days_since_calculation(date_field)
    return if date_field.blank?

    (Time.zone.now - date_field).seconds.in_days.round
  end

  def set_initial_status
    self.status ||= 'unsubmitted'
  end
end
