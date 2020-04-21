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

  def course_not_available?
    course_option.course_not_available?
  end

  def course_not_available_error
    I18n.t('errors.application_choices.course_not_available', descriptor: course.provider_and_name_code)
  end

  def course_closed_on_apply?
    course_option.course_closed_on_apply?
  end

  def course_closed_on_apply_error
    I18n.t(
      'errors.application_choices.course_closed_on_apply',
      course_name_and_code: course.name_and_code,
      provider_name: course.provider.name,
    )
  end

  def course_full?
    course_option.course_full?
  end

  def course_full_error
    I18n.t('errors.application_choices.course_full', descriptor: course.provider_and_name_code)
  end

  def chosen_site_full?
    course_option.no_vacancies?
  end

  def chosen_site_full_error
    I18n.t('errors.application_choices.chosen_site_full', descriptor: course.provider_and_name_code)
  end

  def course_option_availability_error?
    [
      course_not_available?,
      course_closed_on_apply?,
      course_full?,
      chosen_site_full?,
    ].any?
  end

private

  def generate_alphanumeric_id
    SecureRandom.hex(5)
  end

  def set_initial_status
    self.status ||= 'unsubmitted'
  end
end
