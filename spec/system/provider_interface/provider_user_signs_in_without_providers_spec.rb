require 'rails_helper'

RSpec.describe 'Provider user without associated providers attempts to navigate the provider interface' do
  include DfESignInHelpers

  scenario 'Provider user can only access their account page and personal details' do
    given_i_am_a_provider_user
    and_i_have_no_provider_associated_with_my_account
    and_i_sign_in_to_the_provider_interface
    then_i_see_the_access_denied_no_organisation_page
    and_there_is_no_primary_navigation_bar
    and_the_secondary_navigation_bar_only_has_my_account

    when_i_click_on_my_account
    then_i_see_the_my_account_page_with_personal_details_link
    and_no_other_links

    when_i_click_personal_details
    then_i_see_the_personal_details_page
  end

  scenario 'Provider user cannot access find a candidate or other parts of the application' do
    given_i_am_a_provider_user
    and_i_have_no_provider_associated_with_my_account
    and_i_sign_in_to_the_provider_interface
    then_i_see_the_access_denied_no_organisation_page
    and_there_is_no_primary_navigation_bar
    and_the_secondary_navigation_bar_only_has_my_account

    when_i_manually_try_to_access_applications
    then_i_see_the_access_denied_no_organisation_page

    when_i_manually_try_to_access_find_a_candidate
    then_i_see_the_access_denied_no_organisation_page

    when_i_manually_try_to_access_reports
    then_i_see_the_access_denied_no_organisation_page
  end

private

  def given_i_am_a_provider_user
    @provider_user = create(:provider_user, :with_dfe_sign_in, :with_set_up_interviews)
    user_exists_in_dfe_sign_in(email_address: @provider_user.email_address)
  end

  def and_i_have_no_provider_associated_with_my_account
    @provider_user.provider_permissions.destroy_all
  end

  def then_i_see_the_access_denied_no_organisation_page
    expect(page).to have_content('Access denied')
    expect(page).to have_content('You are no longer a member of any organisation.')
    expect(page).to have_content('Contact your administrator if you believe this to be in error.')
  end

  def and_there_is_no_primary_navigation_bar
    expect(page).to have_no_content('Interview schedule')
    expect(page).to have_no_content('Find candidates')
    expect(page).to have_no_content('Reports')
    expect(page).to have_no_content('Activity log')
  end

  def and_the_secondary_navigation_bar_only_has_my_account
    expect(page).to have_no_content('Organisation settings')
  end

  def when_i_click_on_my_account
    click_link_or_button 'Your account'
  end

  def then_i_see_the_my_account_page_with_personal_details_link
    expect(page).to have_content('Your account')
    expect(page).to have_content('Your personal details')
  end

  def and_no_other_links
    expect(page).to have_no_content('Your user permissions')
    expect(page).to have_no_content('Your email notifications')
  end

  def when_i_click_personal_details
    click_link_or_button 'Your personal details'
  end

  def then_i_see_the_personal_details_page
    expect(page).to have_content('Your personal details')
    expect(page).to have_content('First name')
    expect(page).to have_content(@provider_user.first_name)
    expect(page).to have_content('Last name')
    expect(page).to have_content(@provider_user.last_name)
    expect(page).to have_content('Email address')
    expect(page).to have_content(@provider_user.email_address)
    expect(page).to have_content('Change your details or password in DfE Sign-in')
  end

  def when_i_manually_try_to_access_applications
    visit provider_interface_applications_path
  end

  def when_i_manually_try_to_access_find_a_candidate
    visit provider_interface_candidate_pool_root_path
  end

  def when_i_manually_try_to_access_reports
    visit provider_interface_reports_path
  end
end
