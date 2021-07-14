require 'rails_helper'

RSpec.feature 'Sign in as provider user' do
  include DfESignInHelpers

  scenario 'Support user signs in as a provider user' do
    given_i_am_a_support_user
    and_i_am_looking_at_provider_user_details
    when_i_click_the_sign_in_button
    then_i_am_logged_in_as_the_provider_user
    and_i_can_tell_this_is_an_impersonation_from_the_sign_out_link

    when_i_try_to_sign_the_data_sharing_agreement
    then_i_am_told_i_am_a_support_user

    when_i_click_to_return_to_support
    and_i_click_on_stop_impersonating_this_user
    and_i_visit_the_provider_interface
    then_i_am_asked_to_sign_in
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_i_am_looking_at_provider_user_details
    @provider_user = create(:provider_user, :with_provider)
    visit support_interface_provider_user_path(@provider_user)
  end

  def when_i_visit_the_application_form_page
    visit support_interface_application_form_path(@application)
  end

  def when_i_click_the_sign_in_button
    click_on 'Sign in as this provider user'
  end

  def then_i_am_logged_in_as_the_provider_user
    click_on 'Visit Manage'
    expect(page).to have_content 'Data sharing agreement'
  end

  def and_i_can_tell_this_is_an_impersonation_from_the_sign_out_link
    expect(page).not_to have_content('Sign out')
    expect(page).to have_content('Support')
  end

  def when_i_try_to_sign_the_data_sharing_agreement
    provider_name = @provider_user.providers.first.name

    ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
      check "#{provider_name} agrees to comply with the data sharing practices outlined in this agreement"
      click_on t('continue')
    end
  end

  def then_i_am_told_i_am_a_support_user
    expect(page).to have_content 'Cannot be signed by a support user'
  end

  def when_i_click_to_return_to_support
    click_on 'Support'
  end

  def and_i_click_on_stop_impersonating_this_user
    click_on 'Stop impersonating this user'
  end

  def and_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def then_i_am_asked_to_sign_in
    expect(page).to have_content 'You must sign in to your account to manage teacher training applications.'
  end
end
