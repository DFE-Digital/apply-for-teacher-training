class ApplicationChoice < ApplicationRecord
  include Chased

  before_create :set_initial_status

  belongs_to :application_form, touch: true
  belongs_to :course_option
  belongs_to :offered_course_option, class_name: 'CourseOption', optional: true
  has_one :course, through: :course_option
  has_one :site, through: :course_option
  has_one :provider, through: :course
  has_one :accrediting_provider, through: :course, class_name: 'Provider'

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

  def edit_by_expired?
    edit_by.present? && edit_by < Time.zone.now
  end

  def offer_withdrawn?
    rejected? && !offer_withdrawn_at.nil?
  end

private

  def generate_alphanumeric_id
    SecureRandom.hex(5)
  end

  def set_initial_status
    self.status ||= 'unsubmitted'
  end
end
