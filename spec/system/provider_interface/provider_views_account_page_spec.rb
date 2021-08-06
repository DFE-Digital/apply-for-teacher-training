require 'rails_helper'

RSpec.feature 'Provider views account page' do
  include DfESignInHelpers

  # Behaviour tested here has moved to spec/system/provider_interface/provider_user_personal_details_spec.rb
  before { FeatureFlag.deactivate(:account_and_org_settings_changes) }

  scenario 'Provider views their account page' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_applications_for_two_providers
    and_i_sign_in_to_the_provider_interface

    when_i_click_on_the_account_profile_link
    then_i_see_the_account_page_with_my_details
    and_i_see_my_permissions
    and_i_see_a_link_to_dfe_signin_to_change_details
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_manage_applications_for_two_providers
    provider_user_exists_in_apply_database
    @user = ProviderUser.find_by(dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @example_provider = Provider.find_by(code: 'ABC')
    @another_provider = Provider.find_by(code: 'DEF')
  end

  def when_i_click_on_the_account_profile_link
    within('#navigation') do
      click_on('Your account')
    end

    click_on('Profile')
  end

  def then_i_see_the_account_page_with_my_details
    @rows = find('div .govuk-summary-list').all('dd')
    expect(@rows[0].text).to eq(@user.first_name)
    expect(@rows[1].text).to eq(@user.last_name)
    expect(@rows[2].text).to eq(@user.email_address)
    expect(@rows[3].text).to include(@example_provider.name, @another_provider.name)
  end

  def and_i_see_my_permissions
    expect(@rows[4].text).to include('You can only view applications')
  end

  def and_i_see_a_link_to_dfe_signin_to_change_details
    expect(page).to have_link('Change your details or password in DfE Sign-in', href: 'https://profile.signin.education.gov.uk')
  end
end
