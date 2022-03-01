require 'rails_helper'

RSpec.feature 'Candidate tries to sign in without an account' do
  scenario 'Candidate signs in and receives an email inviting them to sign up' do
    given_i_am_a_candidate_without_an_account

    when_i_visit_the_signin_page
    and_i_submit_my_email_address
    then_i_receive_an_email_inviting_me_to_sign_up

    when_i_click_on_the_link_in_my_email
    then_i_am_taken_to_the_sign_up_page
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def when_i_visit_the_signin_page
    visit candidate_interface_sign_in_path
  end

  def and_i_submit_my_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    click_on t('continue')
  end

  def then_i_receive_an_email_inviting_me_to_sign_up
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_in_without_account.email.subject')
  end

  def when_i_click_on_the_link_in_my_email
    current_email.find_css('a').first.click
  end

  def then_i_am_taken_to_the_sign_up_page
    expect(page).to have_current_path(candidate_interface_sign_up_path)
  end
end
