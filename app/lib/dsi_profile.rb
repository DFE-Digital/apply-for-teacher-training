class DsiProfile
  def self.update_profile_from_dfe_sign_in(dfe_user:, local_user:)
    fields_to_update = {}
    if local_user.dfe_sign_in_uid && dfe_user.email_address.present?
      fields_to_update[:email_address] = dfe_user.email_address
    end
    fields_to_update[:first_name] = dfe_user.first_name if dfe_user.first_name.present?
    fields_to_update[:last_name] = dfe_user.last_name if dfe_user.last_name.present?

    local_user.update(fields_to_update)
  end

  def self.update_profile_from_dfe_sign_in_db(omniauth_payload:, local_user:)
    return if local_user == false

    email_address = omniauth_payload.dig('info', 'email')
    first_name = omniauth_payload.dig('info', 'first_name')
    last_name = omniauth_payload.dig('info', 'last_name')

    fields_to_update = {}
    if local_user.dfe_sign_in_uid && email_address.present?
      fields_to_update[:email_address] = email_address
    end
    fields_to_update[:first_name] = first_name if first_name.present?
    fields_to_update[:last_name] = last_name if last_name.present?

    local_user.update(fields_to_update)
  end
end
