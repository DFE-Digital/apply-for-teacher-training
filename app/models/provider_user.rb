class ProviderUser < ApplicationRecord
  include AuthenticatedUsingMagicLinks

  has_many :provider_permissions, dependent: :destroy
  has_many :providers, through: :provider_permissions
  has_many :notes, dependent: :destroy
  has_many :pool_invites, class_name: 'Pool::Invite', foreign_key: 'invited_by_id'
  has_one :find_a_candidate_all_filter, -> { find_candidates_all.order(updated_at: :desc) }, class_name: 'ProviderUserFilter'
  has_one :find_a_candidate_not_seen_filter, -> { find_candidates_not_seen.order(updated_at: :desc) }, class_name: 'ProviderUserFilter'
  has_one :find_candidates_invited_filter, -> { find_candidates_invited.order(updated_at: :desc) }, class_name: 'ProviderUserFilter'

  has_many :pool_views, -> { status_viewed }, class_name: 'ProviderPoolAction', foreign_key: 'actioned_by_id'
  has_many :provider_user_filters
  has_many :dsi_sessions, as: :user, dependent: :destroy
  has_one :notification_preferences, class_name: 'ProviderUserNotificationPreferences'
  attr_accessor :impersonator

  validates :dfe_sign_in_uid, uniqueness: true, allow_nil: true
  validates :email_address,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(email) { email.downcase.strip }

  audited except: [:last_signed_in_at]
  has_associated_audits

  scope :visible_to, lambda { |provider_user|
    providers_that_actor_can_manage_users_for = provider_user.authorisation.providers_that_actor_can_manage_users_for.select(:id)

    users_that_user_can_see = ProviderPermissions.where(
      provider_id: providers_that_actor_can_manage_users_for,
    ).select(:provider_user_id)

    where(id: users_that_user_can_see)
  }

  def self.load_from_session(session)
    dfe_sign_in_user = DfESignInUser.load_from_session(session)
    return unless dfe_sign_in_user

    impersonation = ProviderImpersonation.load_from_session(session)
    return impersonation.provider_user if impersonation

    provider_user = ProviderUser.find_by dfe_sign_in_uid: dfe_sign_in_user.dfe_sign_in_uid
    provider_user || onboard!(dfe_sign_in_user)
  end

  def self.onboard!(dsi_user)
    provider_user = ProviderUser.find_by email_address: dsi_user.email_address
    if provider_user && provider_user.dfe_sign_in_uid.nil?
      provider_user.update!(dfe_sign_in_uid: dsi_user.dfe_sign_in_uid)
      provider_user
    end
  end

  def self.find_or_onboard(omniauth_payload)
    dfe_sign_in_uid = omniauth_payload['uid']
    email_address = omniauth_payload.dig('info', 'email')

    user_with_dfe_sign_in_uid = ProviderUser.find_by(dfe_sign_in_uid:)
    return user_with_dfe_sign_in_uid if user_with_dfe_sign_in_uid.present?

    user_without_dfe_sign_in_uid = ProviderUser.find_by(email_address:, dfe_sign_in_uid: nil)

    if user_without_dfe_sign_in_uid
      user_without_dfe_sign_in_uid.update!(dfe_sign_in_uid:)
      user_without_dfe_sign_in_uid
    end
  end

  def self.load_from_db
    return unless Current.provider_session || Current.support_session

    impersonator = Current.support_session&.user
    impersonated_provider_user = Current.support_session&.impersonated_provider_user
    provider_user = Current.provider_session&.user

    if impersonator.present? && impersonated_provider_user.present?
      return impersonated_provider_user
    end

    provider_user
  end

  def full_name
    "#{first_name} #{last_name}" if first_name.present? && last_name.present?
  end

  def display_name
    return full_name if full_name

    email_address
  end

  def authorisation
    @authorisation = ProviderAuthorisation.new(actor: self)
  end

  def can_manage_organisations?
    provider_permissions.exists?(manage_organisations: true)
  end

  def providers_where_user_can_make_decisions
    Provider
      .joins(:provider_permissions)
      .where(
        'provider_permissions.provider_user_id': id,
        'provider_permissions.make_decisions': true,
      )
  end

  def last_find_candidate_filter
    @find_candidate_filters = provider_user_filters.where(
      kind: %w[find_candidates_all find_candidates_not_seen find_candidates_invited],
    ).order(updated_at: :desc).first
  end
end
