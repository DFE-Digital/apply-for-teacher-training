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

  belongs_to :application_form

  audited associated_with: :application_form

  scope :completed, -> { where('feedback IS NOT NULL') }

  def complete?
    feedback.present?
  end

  def ordinal
    self.application_form.application_references.find_index(self).to_i + 1
  end

  def email_address_not_own
    return if self.application_form.nil?

    candidate_email_address = self.application_form.candidate.email_address

    errors.add(:email_address, :own) if email_address == candidate_email_address
  end
end
