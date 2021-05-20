class ApplicationReference < ApplicationRecord
  include Chased
  include PublishedInAPI

  self.table_name = 'references'

  validates :application_form_id, presence: true

  belongs_to :application_form, touch: true
  has_many :reference_tokens, dependent: :destroy
  has_one :candidate, through: :application_form

  scope :selected, -> { feedback_provided.where(selected: true) }

  audited associated_with: :application_form

  enum feedback_status: {
    cancelled: 'cancelled',
    cancelled_at_end_of_cycle: 'cancelled_at_end_of_cycle',
    not_requested_yet: 'not_requested_yet',
    feedback_requested: 'feedback_requested',
    feedback_provided: 'feedback_provided',
    feedback_refused: 'feedback_refused',
    email_bounced: 'email_bounced',
  }

  enum referee_type: {
    academic: 'academic',
    professional: 'professional',
    school_based: 'school-based',
    character: 'character',
  }

  enum safeguarding_concerns_status: {
    not_answered_yet: 'not_answered_yet',
    no_safeguarding_concerns_to_declare: 'no_safeguarding_concerns_to_declare',
    has_safeguarding_concerns_to_declare: 'has_safeguarding_concerns_to_declare',
    never_asked: 'never_asked',
  }

  def self.pending_feedback_or_failed
    where.not(feedback_status: %i[not_requested_yet feedback_provided])
  end

  def email_address_not_own
    return if application_form.nil?

    candidate_email_address = application_form.candidate.email_address

    errors.add(:email_address, :own) if email_address == candidate_email_address
  end

  def refresh_feedback_token!
    unhashed_token, hashed_token = Devise.token_generator.generate(ReferenceToken, :hashed_token)

    ReferenceToken.create!(application_reference: self, hashed_token: hashed_token)

    unhashed_token
  end

  def self.find_by_unhashed_token(unhashed_token)
    old_token = Devise.token_generator.digest(ApplicationReference, :hashed_sign_in_token, unhashed_token)
    new_token = Devise.token_generator.digest(ReferenceToken, :hashed_token, unhashed_token)

    ReferenceToken.find_by(hashed_token: old_token)&.application_reference ||
      ReferenceToken.find_by(hashed_token: new_token)&.application_reference
  end

  def chase_referee_at
    return unless requested_at

    TimeLimitConfig.chase_referee_by.days.after(requested_at)
  end

  def replace_referee_at
    return unless requested_at

    TimeLimitConfig.replace_referee_by.days.after(requested_at)
  end

  def additional_chase_referee_at
    return unless requested_at

    TimeLimitConfig.additional_reference_chase_calendar_days.days.after(requested_at)
  end

  def next_automated_chase_at
    return unless requested_at
    return if additional_chase_referee_at < Time.zone.now

    Time.zone.now < chase_referee_at ? chase_referee_at : additional_chase_referee_at
  end

  def feedback_overdue?
    return unless replace_referee_at
    return unless feedback_requested? || cancelled_at_end_of_cycle?

    replace_referee_at < Time.zone.now
  end
end
