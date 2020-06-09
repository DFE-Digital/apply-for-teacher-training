module ProviderUserPermissionsHelper
  def permit_make_decisions(dfe_sign_in_uid: 'DFE_SIGN_IN_UID', provider: nil)
    FeatureFlag.activate 'provider_make_decisions_restriction'

    provider_user = ProviderUser.find_by_dfe_sign_in_uid dfe_sign_in_uid
    permissions = if provider
                    provider_user.provider_permissions.where(provider: provider)
                  else
                    provider_user.provider_permissions
                  end

    permissions.update_all(make_decisions: true)
  end

  alias_method :and_i_am_permitted_to_make_decisions_for_my_provider, :permit_make_decisions
  alias_method :and_i_am_permitted_to_make_decisions_for_my_providers, :permit_make_decisions
end
