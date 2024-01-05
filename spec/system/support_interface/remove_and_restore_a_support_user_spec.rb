require 'rails_helper'

RSpec.feature 'Remove and restore support user' do
  include DfESignInHelpers

  scenario 'Confirming removal of a support user then restoring the user' do
    given_i_am_a_support_user
    and_there_are_some_support_users
    when_i_visit_the_support_users_page
    and_i_remove_a_support_user
    then_i_should_see_a_confirmation_page
    and_i_confirm_removal
    then_the_support_user_is_removed
    and_the_support_user_is_not_listed

    when_i_visit_the_removed_support_users_page
    and_i_restore_a_support_user
    and_i_confirm_restoring
    then_the_support_user_is_restored
    and_the_support_user_is_listed
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_some_support_users
    @support_users = create_list(:support_user, 2)
    @removed_user = @support_users.last
    @removed_user_email = @removed_user.email_address
    @removed_user_name = @removed_user.display_name
  end

  def when_i_visit_the_support_users_page
    visit support_interface_support_users_path
  end

  def and_i_remove_a_support_user
    within('.govuk-table__body') do
      click_link_or_button("Remove user #{@removed_user_name}")
    end
  end

  def then_i_should_see_a_confirmation_page
    expect(page.text).to include("Are you sure you want to remove support user #{@removed_user_email}?")
  end

  def and_i_confirm_removal
    click_link_or_button 'Remove support user'
  end

  def then_the_support_user_is_removed
    expect(@removed_user.reload.discarded_at).not_to be_nil
    expect(page.text).to include('Support user removed')
  end

  def and_the_support_user_is_not_listed
    expect(page.text).not_to include(@removed_user_name)
  end

  def when_i_visit_the_removed_support_users_page
    click_link_or_button 'Restore a removed user'
  end

  def and_i_restore_a_support_user
    within('.govuk-table__body') do
      click_link_or_button("Restore user #{@removed_user_name}")
    end
  end

  def and_i_confirm_restoring
    click_link_or_button 'Restore support user'
  end

  def then_the_support_user_is_restored
    expect(@removed_user.reload.discarded_at).to be_nil
    expect(page.text).to include('Support user restored')
  end

  def and_the_support_user_is_listed
    expect(page.text).to include(@removed_user_name)
  end
end
