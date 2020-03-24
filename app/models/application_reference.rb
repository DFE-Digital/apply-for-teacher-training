class ApplicationReference < ApplicationRecord
  include Chased

  self.table_name = 'references'

  validates :name, presence: true, length: { minimum: 2, maximum: 200 }
  validates :email_address, presence: true,
                            email_address: true,
                            length: { maximum: 100 },
                            uniqueness: { case_sensitive: false, scope: :application_form_id }
  validate :email_address_not_own
  validates :relationship, presence: true, word_count: { maximum: 50 }
  validates_presence_of :application_form_id

  belongs_to :application_form, touch: true
  has_many :reference_tokens, dependent: :destroy

  audited associated_with: :application_form

  enum feedback_status: {
    cancelled: 'cancelled',
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

  def ordinal
    self.application_form.application_references.find_index(self).to_i + 1
  end

  def email_address_not_own
    return if self.application_form.nil?

    candidate_email_address = self.application_form.candidate.email_address

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

  def feedback_overdue?
    return unless replace_referee_at
    return unless feedback_requested?

    replace_referee_at < Time.zone.now
  end
end
