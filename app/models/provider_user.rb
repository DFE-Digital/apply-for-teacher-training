class ProviderUser < DfESignInUser
  def provider
    provider_code = Rails.application.config.provider_permissions
      .select { |_code, permitted_uids| permitted_uids.include? dfe_sign_in_uid }
      .keys
      .first

    Provider.find_by(code: provider_code)
  end

  def self.load_from_session(session)
    return nil unless session['dfe_sign_in_user']

    ProviderUser.new(
      email_address: session['dfe_sign_in_user']['email_address'],
      dfe_sign_in_uid: session['dfe_sign_in_user']['dfe_sign_in_uid'],
    )
  end
end
