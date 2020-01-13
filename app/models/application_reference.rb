class ApplicationReference < ApplicationRecord
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

  audited associated_with: :application_form

  # TODO: remove once `feedback_status` is deployed on all environments
  scope :completed, -> { where('feedback IS NOT NULL') }

  enum feedback_status: {
    not_requested_yet: 'not_requested_yet',
    feedback_requested: 'feedback_requested',
    feedback_provided: 'feedback_provided',
    feedback_refused: 'feedback_refused',
  }

  def ordinal
    self.application_form.application_references.find_index(self).to_i + 1
  end

  def email_address_not_own
    return if self.application_form.nil?

    candidate_email_address = self.application_form.candidate.email_address

    errors.add(:email_address, :own) if email_address == candidate_email_address
  end

  def update_token!
    unhashed_token, hashed_token = Devise.token_generator.generate(ApplicationReference, :hashed_sign_in_token)
    update!(hashed_sign_in_token: hashed_token, feedback_status: 'feedback_requested')
    unhashed_token
  end

  def self.find_by_unhashed_token(unhashed_token)
    hashed_token = Devise.token_generator.digest(ApplicationReference, :hashed_sign_in_token, unhashed_token)
    find_by(hashed_sign_in_token: hashed_token)
  end
end
