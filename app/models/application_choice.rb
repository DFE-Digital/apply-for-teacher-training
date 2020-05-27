class ApplicationChoice < ApplicationRecord
  include Chased

  before_create :set_initial_status

  belongs_to :application_form, touch: true
  belongs_to :course_option
  belongs_to :offered_course_option, class_name: 'CourseOption', optional: true
  has_one :course, through: :course_option
  has_one :site, through: :course_option
  has_one :provider, through: :course
  has_one :accredited_provider, through: :course, class_name: 'Provider'

  has_many :notes, dependent: :destroy

  audited associated_with: :application_form

  enum status: {
    unsubmitted: 'unsubmitted',
    awaiting_references: 'awaiting_references',
    application_complete: 'application_complete',
    cancelled: 'cancelled',
    awaiting_provider_decision: 'awaiting_provider_decision',
    offer: 'offer',
    pending_conditions: 'pending_conditions',
    recruited: 'recruited',
    enrolled: 'enrolled',
    rejected: 'rejected',
    declined: 'declined',
    withdrawn: 'withdrawn',
    conditions_not_met: 'conditions_not_met',
  }

  def offer_withdrawn?
    rejected? && !offer_withdrawn_at.nil?
  end

  def offered_option
    offered_course_option || course_option
  end

  def offered_course
    offered_option.course
  end

  def offered_site
    offered_option.site
  end

  delegate :course_not_available?, to: :course_option

  def course_not_available_error
    I18n.t('errors.application_choices.course_not_available', descriptor: course.provider_and_name_code)
  end

  delegate :course_closed_on_apply?, to: :course_option

  def course_closed_on_apply_error
    I18n.t(
      'errors.application_choices.course_closed_on_apply',
      course_name_and_code: course.name_and_code,
      provider_name: course.provider.name,
    )
  end

  delegate :course_full?, to: :course_option

  def course_full_error
    I18n.t('errors.application_choices.course_full', descriptor: course.provider_and_name_code)
  end

  def course_option_full?
    course_option.no_vacancies?
  end

  def chosen_site_full?
    course_option_full? &&
      course.course_options
        .where(vacancy_status: :vacancies)
        .where.not(site: course_option.site)
        .present?
  end

  def chosen_site_full_error
    I18n.t('errors.application_choices.chosen_site_full', descriptor: course.provider_and_name_code)
  end

  def chosen_study_mode_full?
    course_option_full? &&
      course.course_options
        .where(site: course_option.site, vacancy_status: :vacancies)
        .where.not(study_mode: course_option.study_mode)
        .present?
  end

  def chosen_study_mode_full_error
    I18n.t(
      'errors.application_choices.chosen_study_mode_full',
      descriptor: course.provider_and_name_code,
      study_mode: course_option.study_mode.humanize.downcase,
    )
  end

  def course_option_availability_error?
    [
      course_not_available?,
      course_closed_on_apply?,
      course_full?,
      chosen_site_full?,
      chosen_study_mode_full?,
    ].any?
  end

  def edit_by
    raise '`ApplicationChoice#edit_by` has been removed. Use `ApplicationForm#edit_by`.'
  end

  def edit_by=(_)
    raise '`ApplicationChoice#edit_by=` has been removed. Use `ApplicationForm#edit_by=`.'
  end

private

  def generate_alphanumeric_id
    SecureRandom.hex(5)
  end

  def set_initial_status
    self.status ||= 'unsubmitted'
  end
end
