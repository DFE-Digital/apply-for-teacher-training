class ApplicationChoice < ApplicationRecord
  before_create :set_initial_status

  belongs_to :application_form, touch: true
  belongs_to :course_option
  has_one :course, through: :course_option
  has_one :site, through: :course_option
  has_one :provider, through: :course

  audited associated_with: :application_form

  scope :ready_to_send_to_provider, -> {
    joins(application_form: :references)
      .where('feedback is not null')
      .where('edit_by < ?', Time.zone.now)
      .where(status: :application_complete)
      .group('application_choices.id')
      .having('count("references"."feedback") >= 2')
  }

  # ApplicationChoice.joins(application_form: :references).where('feedback is not null').where('edit_by < ?', Time.zone.now)
  #     .where(status: :application_complete)
  #     .group('application_choices.id')
  #     .having('count("references"."feedback") >= 2')
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
  }

private

  def generate_alphanumeric_id
    SecureRandom.hex(5)
  end

  def set_initial_status
    self.status ||= 'unsubmitted'
  end
end
