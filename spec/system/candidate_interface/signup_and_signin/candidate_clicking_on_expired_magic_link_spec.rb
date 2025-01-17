require 'rails_helper'

RSpec.describe 'Candidate clicks on an expired magic link' do
  include SignInHelper

  scenario 'Candidate clicks on a link with an id and expired token link in an email' do
    given_i_am_an_existing_candidate
    when_i_request_a_magic_link

    when_i_click_on_an_expired_magic_link
    then_i_am_redirected_to_the_expired_link_page
    when_i_click_the_button_to_send_me_a_sign_in_email
    then_i_receive_a_sign_in_email
    and_i_see_the_check_your_email_page

    when_i_fill_in_the_sign_in_form
    when_i_click_on_an_expired_magic_link
    then_i_am_redirected_to_the_expired_link_page
  end

  def given_i_am_an_existing_candidate
    @candidate = create(:candidate)
  end

  def when_i_request_a_magic_link
    visit candidate_interface_sign_in_path
    fill_in 'Email address', with: @candidate.email_address
    click_link_or_button t('continue')
  end

  def and_i_received_the_submitted_application_email
    CandidateMailer.application_choice_submitted(@application_choice).deliver_now
  end

  def when_i_click_on_an_expired_magic_link
    travel_temporarily_to(1.hour.from_now + 1.minute) do
      open_email(@candidate.email_address)

      click_magic_link_in_email
    end
  end

  def then_i_am_redirected_to_the_expired_link_page
    expect(page).to have_content(t('authentication.expired_token.heading'))
  end

  def when_i_click_the_button_to_send_me_a_sign_in_email
    click_link_or_button t('authentication.expired_token.button')
  end

  def then_i_receive_a_sign_in_email
    open_email(@candidate.email_address)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def and_i_see_the_check_your_email_page
    expect(page).to have_content('Check your email')
  end

  def when_i_fill_in_the_sign_in_form
    visit candidate_interface_sign_in_path
    fill_in t('authentication.sign_up.email_address.label'), with: @candidate.email_address
    click_link_or_button t('continue')
  end
end
