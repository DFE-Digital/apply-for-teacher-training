class Candidate < ApplicationRecord
  include Chased
  include AuthenticatedUsingMagicLinks

  generates_token_for :unsubscribe_link

  # Only Devise's :timeoutable module is enabled to handle session expiry
  devise :timeoutable
  audited last_signed_in_at: true

  scope :for_transaction_emails, -> { where({ submission_blocked: false, account_locked: false }) }
  scope :for_marketing_or_nudge_emails, -> { for_transaction_emails.where(unsubscribed_from_emails: false) }

  before_validation :downcase_email
  validates :email_address, presence: true, length: { maximum: 100 }, valid_for_notify: true

  has_many :application_forms
  has_many :degree_qualifications, through: :application_forms
  has_many :application_choices, through: :application_forms
  has_many :application_references, through: :application_forms
  has_many :sessions, dependent: :destroy
  has_many :session_errors, dependent: :destroy
  has_one :one_login_auth, dependent: :destroy
  has_one :account_recovery_request, dependent: :destroy
  belongs_to :course_from_find, class_name: 'Course', optional: true
  belongs_to :duplicate_match, foreign_key: 'fraud_match_id', optional: true

  has_many :pool_dismissals, dependent: :destroy, class_name: 'Pool::Dismissal'
  has_many :pool_invites, dependent: :destroy, class_name: 'Pool::Invite'

  PUBLISHED_FIELDS = %w[email_address].freeze

  enum :account_recovery_status, {
    not_started: 'not_started',
    recovered: 'recovered',
    dismissed: 'dismissed',
  }, prefix: true

  enum :pool_status, {
    not_set: 'not_set',
    opt_in: 'opt_in',
    opt_out: 'opt_out',
  }, prefix: true


  def invited?
    invited || false
  end

  after_create do
    update!(candidate_api_updated_at: Time.zone.now)
  end

  before_save do |candidate|
    if candidate.changed.intersect?(PUBLISHED_FIELDS)
      touch_application_choices_and_forms
    end
  end

  delegate :previous_account_email_address, to: :account_recovery_request, allow_nil: true

  def touch_application_choices_and_forms
    return unless application_choices.any?

    application_choices.where(current_recruitment_cycle_year: RecruitmentCycle.current_year).touch_all
    application_forms.where(recruitment_cycle_year: RecruitmentCycle.current_year).touch_all
  end

  def self.for_email(email)
    if (email_address = email&.downcase&.strip).present?
      joins(:one_login_auth).find_by(one_login_auth: { email_address: }) ||
        find_or_initialize_by(email_address:)
    else
      new(email_address: email)
    end
  end

  def current_application
    application_form = application_forms.order(:created_at, :id).last
    application_form || if Time.zone.now > CycleTimetable.apply_deadline
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

  def pseudonymised_id
    # Implementation matches https://github.com/DFE-Digital/dfe-analytics/blob/80015465040513020d0c2b3a2ae45d4f05f3b547/lib/dfe/analytics.rb#L207
    Digest::SHA2.hexdigest(id.to_s)
  end

  def delete
    application_form_ids = application_forms.pluck(:id)
    super

    ApplicationExperience.where(
      experienceable_id: application_form_ids,
      experienceable_type: 'ApplicationForm',
    ).delete_all

    ApplicationWorkHistoryBreak.where(
      breakable_id: application_form_ids,
      breakable_type: 'ApplicationForm',
    ).delete_all
  end

  def recoverable?
    return false if OneLogin.bypass? || FeatureFlag.inactive?(:one_login_candidate_sign_in) || one_login_auth.nil?

    account_recovery_status_not_started? &&
      !application_choices_submitted?
  end

private

  def downcase_email
    email_address.try(:downcase!)
  end

  def application_choices_submitted?
    application_forms.any? do |form|
      form.application_choices.map(&:sent_to_provider_at).any?
    end
  end
end
