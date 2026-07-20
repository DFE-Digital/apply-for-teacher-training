require 'rails_helper'

RSpec.describe 'Candidate requests another magic link too quickly' do
  include SignInHelper

  scenario 'Candidate requests a second sign in magic link' do
    given_i_am_a_candidate_with_an_account

    when_i_go_to_sign_in
    then_i_see_i_should_have_received_an_email

    when_i_click_back_and_go_to_sign_in_again
    then_i_see_that_an_email_has_already_been_sent
  end

  scenario 'Candidate requests a second sign up magic link' do
    given_i_am_a_candidate_without_an_account

    when_i_go_to_sign_up
    and_i_submit_my_email_address
    then_i_see_i_should_have_received_an_email

    when_i_click_back_and_go_to_sign_up_again
    and_i_submit_my_email_address
    then_i_see_that_an_email_has_already_been_sent
  end

  private

  def given_i_am_a_candidate_with_an_account
    @application = create(:application_form)
    @email = @application.candidate.email_address
  end

  def when_i_go_to_sign_in
    visit '/'

    choose 'Yes, sign in'
    fill_in t('authentication.sign_in.email_address.label'), with: @email
    click_link_or_button t('continue')
  end

  def then_i_see_i_should_have_received_an_email
    expect(page).to have_element(:h1, text: 'Check your email', class: 'govuk-heading-xl')
    expect(page).to have_element(
      :p,
      text: 'You should have received a link by email. Follow the link to confirm your email address.',
      class: 'govuk-body-m',
    )
    expect(page).to have_element(
      :p,
      text: 'If it does not arrive in 5 minutes, check your junk folder or try again.',
      class: 'govuk-body',
    )
  end

  def when_i_click_back_and_go_to_sign_in_again
    when_i_go_to_sign_in
  end

  def then_i_see_that_an_email_has_already_been_sent
    expect(page).to have_element(:h1, text: 'We have already sent you an email to sign in', class: 'govuk-heading-l')
    expect(page).to have_element(
      :p,
      text: 'We sent an email with a link to sign in less than a minute ago. Follow the link to sign in.',
      class: 'govuk-body',
    )
    expect(page).to have_element(
      :p,
      text: 'If you have not received the email, wait 1 minute and try again.',
      class: 'govuk-body',
    )
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def when_i_go_to_sign_up
    visit '/'

    choose 'No, I need to create an account'
    click_link_or_button t('continue')
  end

  def when_i_click_back_and_go_to_sign_up_again
    when_i_go_to_sign_up
  end

  def and_i_submit_my_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    click_link_or_button t('continue')
  end
end
