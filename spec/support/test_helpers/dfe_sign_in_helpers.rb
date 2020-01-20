module DfESignInHelpers
  def user_exists_in_dfe_sign_in(email_address: 'email@provider.ac.uk', dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      fake_dfe_sign_in_auth_hash(email_address: email_address, dfe_sign_in_uid: dfe_sign_in_uid),
    )
  end

  alias :provider_exists_in_dfe_sign_in :user_exists_in_dfe_sign_in

  def provider_signs_in_using_dfe_sign_in
    visit provider_interface_sign_in_path
    click_button 'Sign in using DfE Sign-in'
  end

  def support_user_signs_in_using_dfe_sign_in
    visit support_interface_sign_in_path
    click_button 'Sign in using DfE Sign-in'
  end

  def sign_in_as_support_user
    support_user_exists_in_dfe_sign_in(email_address: 'user@apply-support.com', dfe_sign_in_uid: 'abc')
    support_user_signs_in_using_dfe_sign_in
  end

  def provider_user_exists_in_apply_database
    provider = create(:provider, code: 'ABC', name: 'Example Provider')
    create(:provider_user, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  def fake_dfe_sign_in_auth_hash(email_address:, dfe_sign_in_uid:)
    {
      'provider' => 'dfe',
      'uid' => dfe_sign_in_uid,
      'info' => {
        'name' => 'Firstname Lastname',
        'email' => email_address,
        'nickname' => nil,
        'first_name' => 'Firstname',
        'last_name' => 'Lastname',
        'gender' => nil,
        'image' => nil,
        'phone' => nil,
        'urls' => { 'website' => nil },
      },
      'credentials' => {
        'id_token' => '',
        'token' => 'DFE_SIGN_IN_TOKEN',
        'refresh_token' => nil,
        'expires_in' => 3600,
        'scope' => 'email openid',
      },
      'extra' => {
        'raw_info' => {
          'email' => email_address,
          'sub' => dfe_sign_in_uid,
        },
      },
    }
  end

  def support_user_exists_in_dfe_sign_in(email_address: 'email@apply-support.ac.uk', dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    user_exists_in_dfe_sign_in(email_address: email_address, dfe_sign_in_uid: dfe_sign_in_uid)
    user_is_a_support_user(email_address: email_address, dfe_sign_in_uid: dfe_sign_in_uid)
  end

  def user_is_a_support_user(email_address:, dfe_sign_in_uid:)
    SupportUser.find_or_create_by!(
      dfe_sign_in_uid: dfe_sign_in_uid,
      email_address:  email_address,
    )
  end
end
