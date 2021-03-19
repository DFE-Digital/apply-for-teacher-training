class ProviderUser < ApplicationRecord
  include AuthenticatedUsingMagicLinks

  has_many :provider_permissions, dependent: :destroy
  has_many :providers, through: :provider_permissions
  has_many :notes, dependent: :destroy
  has_one :notification_preferences, class_name: 'ProviderUserNotificationPreferences'
  attr_accessor :impersonator

  validates :dfe_sign_in_uid, uniqueness: true, allow_nil: true

  before_save :downcase_email_address

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

  def full_name
    "#{first_name} #{last_name}" if first_name.present? && last_name.present?
  end

  def display_name
    return full_name if full_name

    email_address
  end

  def authorisation
    @authorisation ||= ProviderAuthorisation.new(actor: self)
  end

  def can_manage_organisations?
    provider_permissions.exists?(manage_organisations: true)
  end

private

  def downcase_email_address
    self.email_address = email_address.downcase
  end
end
