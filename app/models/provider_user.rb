class ProviderUser < DfESignInUser
  def provider
    provider_code = Rails.application.config.provider_permissions
      .select { |_code, permitted_uids| permitted_uids.include? dfe_sign_in_uid }
      .keys
      .first

    Provider.find_by(code: provider_code)
  end
end
