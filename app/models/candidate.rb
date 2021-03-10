class Candidate < ApplicationRecord
  include Chased
  include AuthenticatedUsingMagicLinks

  # Only Devise's :timeoutable module is enabled to handle session expiry
  devise :timeoutable
  audited last_signed_in_at: true

  before_validation :downcase_email
  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            length: { maximum: 100 },
                            valid_for_notify: true

  has_one :ucas_match
  has_many :application_forms
  has_many :application_choices, through: :application_forms
  has_many :application_references, through: :application_forms
  belongs_to :course_from_find, class_name: 'Course', optional: true

  def self.for_email(email)
    find_or_initialize_by(email_address: email.downcase) if email
  end

  def current_application
    application_form = application_forms.last
    application_form ||= application_forms.create!
    application_form
  end

  def last_updated_application
    application_forms.max_by(&:updated_at)
  end

  def encrypted_id
    Encryptor.encrypt(id)
  end

private

  def downcase_email
    email_address.try(:downcase!)
  end
end
