require 'rails_helper'

RSpec.describe 'Candidate account' do
  include CandidateHelper
  include SignInHelper

  scenario 'Candidate tries to sign in more than once with same magic link' do
    given_i_am_an_existing_candidate

    when_i_sign_in_and_out
    and_i_try_to_reuse_the_same_magic_link
    then_i_am_prompted_to_get_a_new_magic_link

    when_i_get_a_new_magic_link
    then_i_can_sign_in_again
  end

  def given_i_am_an_existing_candidate
    current_candidate
  end

  def when_i_sign_in_and_out
    visit candidate_interface_sign_in_path
    fill_in 'Email address', with: current_candidate.email_address
    click_link_or_button t('continue')
    open_email(current_candidate.email_address)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')

    @magic_link = current_email.find_css('a').first
    @magic_link.click
    confirm_sign_in
    within '.govuk-header__navigation-list' do
      expect(page).to have_content 'Sign out'
    end

    click_link_or_button 'Sign out'
    expect(page).to have_current_path(candidate_interface_create_account_or_sign_in_path)
  end

  def and_i_try_to_reuse_the_same_magic_link
    @magic_link.click
  end

  def then_i_am_prompted_to_get_a_new_magic_link
    expect(page).to have_content 'The link you used to sign in has expired'
  end

  def when_i_get_a_new_magic_link
    click_link_or_button 'Email me a new link'

    open_email(current_candidate.email_address)
    @new_magic_link = current_email.find_css('a').first
  end

  def then_i_can_sign_in_again
    @new_magic_link.click
    confirm_sign_in
    within '.govuk-header__navigation-list' do
      expect(page).to have_content 'Sign out'
    end
  end
end
