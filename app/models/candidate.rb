class Candidate < ApplicationRecord
  include Chased
  include AuthenticatedUsingMagicLinks

  # Only Devise's :timeoutable module is enabled to handle session expiry
  devise :timeoutable
  audited last_signed_in_at: true

  before_validation :downcase_email
  validates :email_address, presence: true, length: { maximum: 100 }, valid_for_notify: true

  has_one :ucas_match
  has_many :application_forms
  has_many :application_choices, through: :application_forms
  has_many :application_references, through: :application_forms
  belongs_to :course_from_find, class_name: 'Course', optional: true

  after_create do
    update!(candidate_api_updated_at: Time.zone.now)
  end

  def self.for_email(email)
    find_or_initialize_by(email_address: email.downcase) if email
  end

  def current_application
    application_form = application_forms.order(:created_at).last
    application_form || if Time.zone.now > CycleTimetable.apply_1_deadline
                          application_forms.create!(recruitment_cycle_year: CycleTimetable.next_year)
                        else
                          application_forms.create!
                        end
  end

  def last_updated_application
    application_forms.max_by(&:updated_at)
  end

  def encrypted_id
    Encryptor.encrypt(id)
  end

  def public_id
    "C#{id}"
  end

private

  def downcase_email
    email_address.try(:downcase!)
  end
end
