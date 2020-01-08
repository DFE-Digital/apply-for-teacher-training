require 'rails_helper'

RSpec.feature 'Managing provider users' do
  include DfESignInHelpers

  scenario 'creating a new provider user' do
    given_i_am_a_support_user
    and_providers_exist

    when_i_visit_the_support_console
    and_i_click_the_users_link
    and_i_click_the_manange_provider_users_link
    and_i_click_the_add_user_link
    and_i_enter_the_users_email_and_dsi_uid
    and_i_select_a_provider
    and_i_click_add_user

    then_i_should_see_the_list_of_provider_users
    and_i_should_see_the_user_i_created
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_providers_exist
    create(:provider, name: 'Example provider', code: 'ABC')
  end

  def when_i_visit_the_support_console
    visit support_interface_path
  end

  def and_i_click_the_users_link
    click_link 'Users'
  end

  def and_i_click_the_manange_provider_users_link
    click_link 'Provider users'
  end

  def and_i_enter_the_users_email_and_dsi_uid
    fill_in 'support_interface_provider_user_form[email_address]', with: 'harrison@example.com'
    fill_in 'support_interface_provider_user_form[dfe_sign_in_uid]', with: '12345-ABCDE'
  end

  def and_i_select_a_provider
    check 'Example provider (ABC)'
  end

  def and_i_click_the_add_user_link
    click_link 'Add provider user'
  end

  def and_i_click_add_user
    click_button 'Add provider user'
  end

  def then_i_should_see_the_list_of_provider_users
    expect(page).to have_title('Provider users')
  end

  def and_i_should_see_the_user_i_created
    expect(page).to have_content('harrison@example.com')
  end
end
