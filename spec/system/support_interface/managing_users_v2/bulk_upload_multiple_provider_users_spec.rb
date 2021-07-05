require 'rails_helper'

RSpec.feature 'bulk upload provider users' do
  include DfESignInHelpers
  include DsiAPIHelper

  before do
    FeatureFlag.activate(:new_provider_user_flow)
    FeatureFlag.activate(:interview_permissions)
  end

  scenario 'bulk upload multiple provider users', with_audited: true do
    given_dfe_signin_is_configured
    and_i_am_a_support_user
    and_a_provider_exists

    when_i_visit_the_providers_page
    and_i_click_on_users
    and_i_click_add_multiple_users
    then_i_should_see_the_add_multiple_user_form

    when_i_click_continue
    then_i_should_see_a_form_validation_error

    when_i_enter_the_users_details
    and_i_click_continue
    then_i_should_see_the_permissions_form_for_the_first_user

    when_i_click_back
    then_i_should_see_the_add_multiple_user_form

    when_i_click_continue
    and_i_edit_the_email_address_for_the_first_user
    and_i_add_permissions_for_the_first_user
    and_i_click_continue
    then_i_should_see_the_permissions_form_for_the_second_user

    when_i_click_back
    then_i_should_see_the_permissions_form_for_the_first_user

    when_i_click_continue
    and_i_add_permissions_for_the_second_user
    and_i_click_continue
    then_i_should_see_the_provider_user_review_page

    when_i_click_back
    then_i_should_see_the_permissions_form_for_the_second_user

    when_i_click_continue
    then_i_can_see_the_check_users_page

    when_i_click_change_within_the_second_user_summary
    then_i_should_see_the_edit_permissions_form_for_the_second_user
    and_the_permissions_i_selected_are_checked

    when_i_edit_permissions_for_the_second_user
    and_i_click_continue
    then_i_can_see_the_check_users_page

    when_i_click_add_users
    then_i_see_the_provider_users_page
    and_i_see_two_users_have_been_successfully_created
  end

  def given_dfe_signin_is_configured
    dsi_api_response(success: true)
  end

  def and_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_a_provider_exists
    @provider = create(:provider, name: 'Gorse SCITT', code: 'ABC')

    create(:course, :open_on_apply, provider: @provider)
  end

  def when_i_visit_the_providers_page
    visit support_interface_provider_path(@provider)
  end

  def and_i_click_on_users
    click_on 'Users'
  end

  def and_i_click_add_multiple_users
    click_on 'Add multiple users'
  end

  def then_i_should_see_the_add_multiple_user_form
    expect(page).to have_content("Add users to #{@provider.name}")
  end

  def when_i_enter_the_users_details
    user_details = "first_name_one,last_name_one,first_name_one@foo.com\nfirst_name_two\tlast_name_two\tfirst_name_two@foo.com"
    fill_in 'support_interface_multiple_provider_users_wizard[provider_users]', with: user_details
  end

  def and_i_click_continue
    click_on 'Continue'
  end

  def when_i_click_continue
    and_i_click_continue
  end

  def then_i_should_see_a_form_validation_error
    expect(page).to have_content("Enter the users' details")
  end

  def then_i_should_see_the_permissions_form_for_the_first_user
    expect(page).to have_content('Add user (1 of 2)')
    expect(page).to have_content(@provider.name)
    expect(page).to have_field('support_interface_create_single_provider_user_form[first_name]', with: 'first_name_one')
  end

  def and_i_add_permissions_for_the_first_user
    check 'Manage users'
    check 'Manage organisational permissions'
    check 'Access safeguarding information'
    check 'Make decisions'
    check 'Set up interviews'
    check 'Access diversity information'
  end

  def then_i_should_see_the_permissions_form_for_the_second_user
    expect(page).to have_content('Add user (2 of 2)')
    expect(page).to have_content(@provider.name)
    expect(page).to have_field('support_interface_create_single_provider_user_form[last_name]', with: 'last_name_two')
  end

  def then_i_should_see_the_edit_permissions_form_for_the_second_user
    expect(page).to have_content('Add user (2 of 2)')
    expect(page).to have_content(@provider.name)
    expect(page).to have_field('support_interface_create_single_provider_user_form[last_name]', with: 'last_name_two')
  end

  def and_i_edit_the_email_address_for_the_first_user
    fill_in('Email address', with: 'superfoo@superbar.com')
  end

  def and_i_add_permissions_for_the_second_user
    and_i_add_permissions_for_the_first_user
  end

  def when_i_edit_permissions_for_the_second_user
    check 'Manage users'
    check 'Manage organisational permissions'
  end

  def when_i_click_back
    click_on 'Back'
  end

  def then_i_should_see_the_provider_user_review_page
    expect(page).to have_content("#{@provder_name} Check details and add users")
    expect(page).to have_content('first_name_one')
    expect(page).to have_content('first_name_two')
  end

  def and_i_click_add_users
    click_on 'Add users'
  end

  def when_i_click_add_users
    click_on 'Add users'
  end

  def and_the_permissions_i_selected_are_checked
    expect(find_field('Manage users')).to be_checked
    expect(find_field('Manage organisational permissions')).to be_checked
    expect(find_field('Access safeguarding information')).to be_checked
    expect(find_field('Make decisions')).to be_checked
    expect(find_field('Set up interviews')).to be_checked
    expect(find_field('Access diversity information')).to be_checked
  end

  def then_i_see_the_provider_users_page
    expect(page).to have_content(@provider.name_and_code.to_s)
  end

  def then_i_can_see_the_check_users_page
    expect(page).to have_content('Check details and add users')
  end

  def when_i_click_change_within_the_second_user_summary
    all(:css, '.govuk-link').last.click
  end

  def and_i_see_two_users_have_been_successfully_created
    expect(page).to have_content('2 users added')
  end
end
