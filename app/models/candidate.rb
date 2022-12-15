class Candidate < ApplicationRecord
  include Chased
  include AuthenticatedUsingMagicLinks

  # Only Devise's :timeoutable module is enabled to handle session expiry
  devise :timeoutable
  audited last_signed_in_at: true

  before_validation :downcase_email
  validates :email_address, presence: true, length: { maximum: 100 }, valid_for_notify: true

  has_many :application_forms
  has_many :application_choices, through: :application_forms
  has_many :application_references, through: :application_forms
  belongs_to :course_from_find, class_name: 'Course', optional: true
  belongs_to :duplicate_match, foreign_key: 'fraud_match_id', optional: true

  PUBLISHED_FIELDS = %w[email_address].freeze

  after_create do
    update!(candidate_api_updated_at: Time.zone.now)
  end

  before_save do |candidate|
    if candidate.changed.intersect?(PUBLISHED_FIELDS)
      touch_application_choices_and_forms
    end
  end

  def touch_application_choices_and_forms
    return unless application_choices.any?

    application_choices.where(current_recruitment_cycle_year: RecruitmentCycle.current_year).touch_all
    application_forms.where(recruitment_cycle_year: RecruitmentCycle.current_year).touch_all
  end

  def self.for_email(email)
    find_or_initialize_by(email_address: email.downcase) if email
  end

  def current_application
    application_form = application_forms.order(:created_at, :id).last
    application_form || if Time.zone.now > CycleTimetable.apply_1_deadline
                          application_forms.create!(recruitment_cycle_year: CycleTimetable.next_year)
                        else
                          application_forms.create!
                        end
  end

  def current_application_choices
    current_application.application_choices
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

  def in_apply_2?
    application_forms.current_cycle.exists?(phase: 'apply_2')
  end

  def load_tester?
    email_address.ends_with?('@loadtest.example.com') && !HostingEnvironment.production?
  end

  def never_signed_in?
    last_signed_in_at.nil?
  end

private

  def downcase_email
    email_address.try(:downcase!)
  end
end
