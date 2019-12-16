require 'rails_helper'

RSpec.feature 'Managing support users' do
  include DfESignInHelpers

  scenario 'creating a new support user' do
    given_i_am_a_support_user

    when_i_visit_the_support_console
    and_i_click_the_users_link
    and_i_click_the_manange_support_users_link
    and_i_click_the_add_user_link
    and_i_enter_the_users_email_and_dsi_uid
    and_i_click_add_user

    then_i_should_see_the_list_of_support_users
    and_i_should_see_the_user_i_created
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_a_support_user_exists_in_the_database
    create(:support_user, email_address: 'person@example.com')
  end

  def when_i_visit_the_support_console
    visit support_interface_path
  end

  def and_i_click_the_users_link
    click_link 'Users'
  end

  def and_i_click_the_manange_support_users_link
    click_link 'Manage support users'
  end

  def and_i_enter_the_users_email_and_dsi_uid
    fill_in 'support_user[email_address]', with: 'harrison@example.com'
    fill_in 'support_user[dfe_sign_in_uid]', with: '12345-ABCDE'
  end

  def and_i_click_the_add_user_link
    click_link 'Add support user'
  end

  def and_i_click_add_user
    click_button 'Add support user'
  end

  def then_i_should_see_the_list_of_support_users
    expect(page).to have_title('Support users')
  end

  def and_i_should_see_the_user_i_created
    expect(page).to have_content('harrison@example.com')
  end
end
