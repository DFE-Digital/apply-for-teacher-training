class ProviderUser < ActiveRecord::Base
  has_many :provider_permissions, dependent: :destroy
  has_many :providers, through: :provider_permissions
  has_many :notes, dependent: :destroy

  validates :dfe_sign_in_uid, uniqueness: true, allow_nil: true

  before_save :downcase_email_address

  audited except: [:last_signed_in_at]
  has_associated_audits

  scope :visible_to, lambda { |provider_user|
    providers_that_user_can_manage = provider_user.provider_permissions.manage_users.select(:provider_id)

    users_that_user_can_see = ProviderPermissions.where(
      provider_id: providers_that_user_can_manage,
    ).select(:provider_user_id)

    where(id: users_that_user_can_see)
  }

  def self.load_from_session(session)
    dfe_sign_in_user = DfESignInUser.load_from_session(session)
    return unless dfe_sign_in_user

    approved_user = ProviderUser.find_by dfe_sign_in_uid: dfe_sign_in_user.dfe_sign_in_uid
    approved_user || onboard!(dfe_sign_in_user)
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
