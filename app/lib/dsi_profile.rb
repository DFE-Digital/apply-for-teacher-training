class DsiProfile
  def self.update_profile_from_omniauth_payload(omniauth_payload:, local_user:)
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
