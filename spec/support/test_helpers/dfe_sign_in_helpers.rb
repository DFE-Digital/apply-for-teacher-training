module DfESignInHelpers
  def user_exists_in_dfe_sign_in(email_address: 'email@provider.ac.uk', dfe_sign_in_uid: 'DFE_SIGN_IN_UID', first_name: nil, last_name: nil)
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      fake_dfe_sign_in_auth_hash(
        email_address:,
        dfe_sign_in_uid:,
        first_name:,
        last_name:,
      ),
    )
  end

  alias provider_exists_in_dfe_sign_in user_exists_in_dfe_sign_in

  def provider_signs_in_using_dfe_sign_in
    visit provider_interface_path
    first("a[href='#{provider_interface_sign_in_path}']").click
    click_link_or_button 'Sign in using DfE Sign-in'
  end

  alias and_i_sign_in_to_the_provider_interface provider_signs_in_using_dfe_sign_in
  alias when_i_sign_in_to_the_provider_interface provider_signs_in_using_dfe_sign_in

  def support_user_signs_in_using_dfe_sign_in
    visit support_interface_sign_in_path
    click_link_or_button 'Sign in using DfE Sign-in'
  end

  def sign_in_as_support_user
    support_user_exists_in_dfe_sign_in(email_address: 'user@apply-support.com', dfe_sign_in_uid: 'abc')
    support_user_signs_in_using_dfe_sign_in
  end
  alias given_i_am_signed_in_as_a_support_user sign_in_as_support_user

  def provider_user_exists_in_apply_database(provider_code: 'ABC', email_address: 'email@provider.ac.uk')
    provider_one = Provider.find_by(code: provider_code) if provider_code
    provider_one ||= create(:provider, code: provider_code, name: 'Example Provider')

    provider_two = create(:provider, code: 'DEF', name: 'Another Provider')

    create(:provider_user,
           :with_notifications_enabled,
           providers: [provider_one, provider_two],
           dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
           email_address:)
  end

  def provider_user_exists_in_apply_database_with_multiple_providers(providers: nil)
    providers ||= [
      create(:provider, code: 'ABC', name: 'Example Provider'),
      create(:provider, code: 'DEF', name: 'Example Provider'),
      create(:provider, code: 'GHI', name: 'Example Provider'),
    ]

    create(:provider_user, providers:, dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  def fake_dfe_sign_in_auth_hash(email_address:, dfe_sign_in_uid:, first_name:, last_name:)
    {
      'provider' => 'dfe',
      'uid' => dfe_sign_in_uid,
      'info' => {
        'name' => 'Firstname Lastname',
        'email' => email_address,
        'nickname' => nil,
        'first_name' => first_name,
        'last_name' => last_name,
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
    user_exists_in_dfe_sign_in(email_address:, dfe_sign_in_uid:)
    user_is_a_support_user(email_address:, dfe_sign_in_uid:)
  end

  def user_is_a_support_user(email_address:, dfe_sign_in_uid:)
    SupportUser.find_or_create_by!(
      dfe_sign_in_uid:,
      email_address:,
    )
  end

  def user_is_a_removed_support_user(email_address:, dfe_sign_in_uid:, discarded_at: Date.new(2020, 1, 1))
    SupportUser.find_or_create_by!(
      dfe_sign_in_uid:,
      email_address:,
      discarded_at:,
    )
  end

  def sign_in_as(email_address:, dfe_sign_in_uid:)
    click_link_or_button('Sign out') if has_link?('Sign out', wait: 0)
    browser = Capybara.current_session.driver.browser
    browser.clear_cookies
    provider_exists_in_dfe_sign_in(email_address:, dfe_sign_in_uid:)
    visit provider_interface_applications_path
    click_link_or_button 'Sign in using DfE Sign-in'
    visit provider_interface_path
  end
end
