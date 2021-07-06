module ProviderUserPermissionsHelper
  def permit_make_decisions!(dfe_sign_in_uid: 'DFE_SIGN_IN_UID', provider: nil)
    provider_user = ProviderUser.find_by_dfe_sign_in_uid dfe_sign_in_uid
    permissions = if provider
                    provider_user.provider_permissions.where(provider: provider)
                  else
                    provider_user.provider_permissions
                  end

    permissions.update_all(make_decisions: true)
  end

  def deny_make_decisions!(dfe_sign_in_uid: 'DFE_SIGN_IN_UID', provider: nil)
    provider_user = ProviderUser.find_by_dfe_sign_in_uid dfe_sign_in_uid
    permissions = if provider
                    provider_user.provider_permissions.where(provider: provider)
                  else
                    provider_user.provider_permissions
                  end

    permissions.update_all(make_decisions: false)
  end

  def permit_set_up_interviews!(dfe_sign_in_uid: 'DFE_SIGN_IN_UID', provider: nil)
    provider_user = ProviderUser.find_by_dfe_sign_in_uid dfe_sign_in_uid
    permissions = if provider
                    provider_user.provider_permissions.where(provider: provider)
                  else
                    provider_user.provider_permissions
                  end

    permissions.update_all(set_up_interviews: true)
  end
end
