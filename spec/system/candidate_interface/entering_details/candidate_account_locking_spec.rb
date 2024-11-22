require 'rails_helper'

RSpec.describe 'Candidate account locking' do
  include CandidateHelper
  include SignInHelper

  scenario 'Candidate attempts to continue their application while account is locked' do
    given_i_am_signed_in
    and_i_visit_the_site
    and_my_account_is_locked

    when_i_click_on_contact_information
    then_i_am_redirected_to_the_account_locked_page

    when_i_try_to_login_again
    then_i_am_redirected_to_the_account_locked_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_details_path
  end

  def and_my_account_is_locked
    @email_address = current_candidate.email_address
    current_candidate.update!(account_locked: true)
  end

  def when_i_click_on_contact_information
    click_link_or_button t('page_titles.contact_information')
  end

  def then_i_am_redirected_to_the_account_locked_page
    expect(page).to have_current_path(candidate_interface_account_locked_path)
    expect(page).to have_content('You can no longer access this account')
  end

  def when_i_try_to_login_again
    visit candidate_interface_sign_in_path
    fill_in t('authentication.sign_up.email_address.label'), with: @email_address
    click_link_or_button t('continue')
    open_email(@email_address)
    click_magic_link_in_email
    confirm_sign_in
  end
end
