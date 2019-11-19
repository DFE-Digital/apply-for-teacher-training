module DfESignInHelpers
  def provider_exists_in_dfe_sign_in(email: 'email@example.com')
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      info: { email: email },
    )
  end

  def provider_signs_in_using_dfe_sign_in
    visit provider_interface_path
    click_link 'Sign in using DfE Sign-in'
  end
end
