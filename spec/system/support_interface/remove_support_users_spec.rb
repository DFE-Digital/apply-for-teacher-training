require 'rails_helper'

RSpec.feature 'Remove a support user' do
  include DfESignInHelpers

  scenario 'Confirming removal of a support user' do
    given_i_am_a_support_user
    and_there_are_some_support_users
    when_i_visit_the_support_users_page
    and_i_delete_a_support_user
    then_i_should_see_a_confirmation_page
    and_i_confirm_deletion
    then_the_support_user_is_deleted_from_the_database
    and_the_support_user_is_not_listed
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_some_support_users
    @support_users = create_list(:support_user, 2)
    @deleted_user_email = @support_users.last.email_address
  end

  def when_i_visit_the_support_users_page
    visit support_interface_support_users_path
  end

  def and_i_delete_a_support_user
    within('.govuk-table__body') do
      click_on("Delete user #{@deleted_user_email}")
    end
  end

  def then_i_should_see_a_confirmation_page
    expect(page.text).to include("Are you sure you want to delete support user #{@deleted_user_email}?")
  end

  def and_i_confirm_deletion
    click_on 'Delete support user'
  end

  def then_the_support_user_is_deleted_from_the_database
    expect(SupportUser.find_by_email_address(@deleted_user_email)).to be_nil
  end

  def and_the_support_user_is_not_listed
    expect(page.text).not_to include(@deleted_user_email)
  end
end
