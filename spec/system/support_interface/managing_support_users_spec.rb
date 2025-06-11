require 'rails_helper'

RSpec.describe 'Managing support users' do
  include DfESignInHelpers

  scenario 'creating a new support user', :with_audited do
    given_i_am_a_support_user

    when_i_visit_the_support_console
    and_i_click_the_manage_support_users_link
    and_i_click_the_add_user_link
    and_i_enter_the_users_email_and_dsi_uid
    and_i_click_add_user

    then_i_see_the_list_of_support_users
    and_i_see_the_user_i_created

    when_i_click_on_the_user
    then_i_can_see_the_audit_history

    when_i_go_back_to_the_manage_support_users_page
    and_i_submit_the_same_email_address_again
    then_i_see_an_error
  end

  scenario 'orders users by last login date', :with_audited do
    given_i_am_a_support_user

    when_i_visit_the_support_console
    and_there_are_other_support_users_in_the_db
    and_i_click_the_manage_support_users_link
    and_i_see_the_last_login_date_column
    then_i_see_users_ordered_by_oldest_login
  end

  def then_i_see_users_ordered_by_oldest_login
    emails = page.all('tbody .govuk-table__row td:first-child a.govuk-link').map(&:text)

    expect(emails).to eq([
      'isignedinyesterday@msn.com',
      'user@apply-support.com',
      'isignedintoday@msn.com',
      'isignedintomorrow@msn.com',
    ])
  end

  def and_i_see_the_last_login_date_column
    expect(page).to have_css('th.govuk-table__header', text: 'Last Login Date')
  end

  def and_there_are_other_support_users_in_the_db
    SupportUser.create(email_address: 'isignedinyesterday@msn.com', last_signed_in_at: Time.zone.yesterday, dfe_sign_in_uid: 'Y')
    SupportUser.find_by(email_address: 'user@apply-support.com')
          .update!(last_signed_in_at: Time.zone.now.beginning_of_day)
    SupportUser.create(email_address: 'isignedintoday@msn.com', last_signed_in_at: Time.zone.now, dfe_sign_in_uid: 'TD')
    SupportUser.create(email_address: 'isignedintomorrow@msn.com', last_signed_in_at: Time.zone.tomorrow, dfe_sign_in_uid: 'TM')
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_support_console
    visit support_interface_path
  end

  def and_i_click_the_manage_support_users_link
    click_link_or_button 'Settings'
    click_link_or_button 'Support users'
  end

  def and_i_enter_the_users_email_and_dsi_uid
    fill_in 'support_user[email_address]', with: 'harrison@example.com'
    fill_in 'support_user[dfe_sign_in_uid]', with: '12345-ABCDE'
  end

  def and_i_click_the_add_user_link
    click_link_or_button 'Add support user'
  end

  def and_i_click_add_user
    click_link_or_button 'Add support user'
  end

  def then_i_see_the_list_of_support_users
    expect(page).to have_title('Support users')
  end

  def and_i_see_the_user_i_created
    expect(page).to have_content('harrison@example.com')
  end

  def when_i_go_back_to_the_manage_support_users_page
    click_link_or_button 'Support users'
  end

  def and_i_submit_the_same_email_address_again
    and_i_click_the_add_user_link
    and_i_enter_the_users_email_and_dsi_uid
    and_i_click_add_user
  end

  def when_i_click_on_the_user
    click_link_or_button 'harrison@example.com'
  end

  def then_i_can_see_the_audit_history
    expect(page).to have_content('Create Support User')
    expect(page).to have_content('email_address')
    expect(page).to have_content('harrison@example.com')
  end

  def then_i_see_an_error
    expect(page).to have_content 'A support user with this email address already exists'
  end
end
