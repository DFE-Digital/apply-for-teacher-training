require 'rails_helper'

RSpec.describe 'Managing support users' do
  include DfESignInHelpers

  scenario 'creating a new support user', :with_audited do
    given_i_am_a_support_user

    when_i_visit_the_support_console
    and_i_click_the_manage_support_users_link
    and_i_click_the_add_user_link
    and_i_enter_the_users_email_and_dsi_uid
    and_i_select_the_user_support_role
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

  scenario 'editing a support user role', :with_audited do
    given_i_am_a_support_user
    when_i_visit_the_support_console
    and_there_are_other_support_users_in_the_db
    and_i_click_the_manage_support_users_link
    then_i_see_users_ordered_by_oldest_login

    when_i_click_on_change_role_for_the_first_support_user
    then_i_see_the_select_a_role_page

    when_i_select_the_user_support_role
    and_i_click_update_role
    then_i_see_the_support_user_role_was_updated
    and_i_see_the_support_user_role_is_user_support
  end

private

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
    expect(page).to have_text('harrison@example.com')
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
    expect(page).to have_text('Create Support User')
    expect(page).to have_text('email_address')
    expect(page).to have_text('harrison@example.com')
  end

  def then_i_see_an_error
    expect(page).to have_text 'A support user with this email address already exists'
  end

  def and_i_select_the_user_support_role
    choose "User support"
  end
  alias_method :when_i_select_the_user_support_role, :and_i_select_the_user_support_role

  def when_i_click_on_change_role_for_the_first_support_user
    @first_support_user = SupportUser.find_by(email_address: 'isignedinyesterday@msn.com')
    row = page.find('tr', text: 'isignedinyesterday@msn.com')

    within(row) do
      click_on 'Change role'
    end
  end

  def then_i_see_the_select_a_role_page
    expect(page).to have_current_path(edit_support_interface_support_user_path(@first_support_user))

    expect(page).to have_element(:span, text: @first_support_user.display_name, class: 'govuk-caption-l')
    expect(page).to have_element(:legend, text: 'Select a role')
    expect(page).to have_element(
      :div,
      text: 'Only give a user the role they need to do their job. ' \
            'Giving a user a role they do not need could allow them to view sensitive data or change how the service works.',
      class: 'govuk-warning-text',
    )
    expect(page).to have_link(
      'View full details for each role, including what they can access and change',
      href: roles_support_interface_support_users_path,
    )

    expect(page).to have_field('User support', type: :radio)
    expect(page).to have_field('Technical management', type: :radio)
    expect(page).to have_field('Service administration', type: :radio)
    expect(page).to have_field('Research and design', type: :radio)
  end

  def and_i_click_update_role
    click_on 'Update role'
  end

  def then_i_see_the_support_user_role_was_updated
    expect(page).to have_text('Support user role updated')
  end

  def and_i_see_the_support_user_role_is_user_support
    row = page.find('tr', text: 'isignedinyesterday@msn.com')

    within(row) do
      expect(page).to have_text('User support')
    end
  end
end
