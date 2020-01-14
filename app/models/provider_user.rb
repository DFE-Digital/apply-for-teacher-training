class ProviderUser < ActiveRecord::Base
  has_and_belongs_to_many :providers

  validates :dfe_sign_in_uid, presence: true, uniqueness: true, allow_nil: true

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
end
