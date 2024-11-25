require 'rails_helper'

RSpec.describe 'Candidate tries to sign up using magic link with an invalid token' do
  include SignInHelper

  scenario 'Candidate signs in and receives an email inviting them to sign up' do
    given_i_am_a_candidate_with_an_account

    when_i_go_to_sign_in
    then_i_receive_an_email_inviting_me_to_sign_in

    when_i_click_back_and_go_to_sign_in_again
    then_i_receive_a_second_email_inviting_me_to_sign_in

    when_i_click_on_the_link_in_my_email
    and_i_confirm_the_sign_in
    then_i_see_my_application_form
  end

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

  def then_i_receive_an_email_inviting_me_to_sign_in
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def when_i_click_back_and_go_to_sign_in_again
    when_i_go_to_sign_in
  end

  def then_i_receive_a_second_email_inviting_me_to_sign_in
    open_email(@email)
    expect(all_emails.size).to eq 2
  end

  def when_i_click_on_the_link_in_my_email
    click_magic_link_in_email
  end

  def and_i_confirm_the_sign_in
    confirm_sign_in
  end

  def then_i_see_my_application_form
    expect(page).to have_current_path(candidate_interface_details_path)
  end
end
