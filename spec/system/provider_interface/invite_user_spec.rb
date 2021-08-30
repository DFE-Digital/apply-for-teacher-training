require 'rails_helper'

RSpec.feature 'Provider user invitation' do
  include DfESignInHelpers
  include DsiAPIHelper

  before { FeatureFlag.activate(:account_and_org_settings_changes) }

  scenario 'Provider invites user' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface
    and_i_go_to_the_users_page
    then_i_cannot_see_the_invite_user_button

    given_i_can_manage_users
    and_i_go_to_the_users_page
    then_i_can_see_the_invite_user_button

    when_i_click_on_invite_user
    then_i_see_a_personal_details_form

    when_i_fill_in_personal_details_with_an_email_that_already_exists
    and_i_click_continue
    then_i_see_a_duplicate_email_validation_error
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in

    @provider = create(:provider, :with_signed_agreement, code: 'ABC')
    @provider_user = create(
      :provider_user,
      providers: [@provider],
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      email_address: 'email@provider.ac.uk',
    )
  end

  def and_i_go_to_the_users_page
    click_on 'Organisation settings', match: :first
    click_on 'Users', match: :first
  end

  def then_i_cannot_see_the_invite_user_button
    expect(page).not_to have_link('Invite user')
  end

  def given_i_can_manage_users
    @provider_user.provider_permissions.update_all(manage_users: true)
  end

  def then_i_can_see_the_invite_user_button
    expect(page).to have_link('Invite user')
  end

  def when_i_click_on_invite_user
    click_on 'Invite user'
  end

  def then_i_see_a_personal_details_form
    expect(page).to have_selector('h1', text: 'Personal details')
  end

  def when_i_fill_in_personal_details_with_an_email_that_already_exists
    fill_in 'First name', with: 'Johnathy'
    fill_in 'Last name', with: 'Smithinson'
    fill_in 'Email address', with: 'email@provider.ac.uk'
  end

  def and_i_click_continue
    click_on 'Continue'
  end

  def then_i_see_a_duplicate_email_validation_error
    expect(page).to have_content("A user with this email address already has access to #{@provider.name}")
  end
end
