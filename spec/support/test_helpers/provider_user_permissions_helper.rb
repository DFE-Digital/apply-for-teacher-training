module ProviderUserPermissionsHelper
  def permit_make_decisions!(dfe_sign_in_uid: 'DFE_SIGN_IN_UID', provider: nil)
    FeatureFlag.activate(:providers_can_manage_users_and_permissions)

    provider_user = ProviderUser.find_by_dfe_sign_in_uid dfe_sign_in_uid
    permissions = if provider
                    provider_user.provider_permissions.where(provider: provider)
                  else
                    provider_user.provider_permissions
                  end

    permissions.update_all(make_decisions: true)
  end

  def deny_make_decisions!(dfe_sign_in_uid: 'DFE_SIGN_IN_UID', provider: nil)
    FeatureFlag.activate(:providers_can_manage_users_and_permissions)

    provider_user = ProviderUser.find_by_dfe_sign_in_uid dfe_sign_in_uid
    permissions = if provider
                    provider_user.provider_permissions.where(provider: provider)
                  else
                    provider_user.provider_permissions
                  end

    permissions.update_all(make_decisions: false)
  end
end
