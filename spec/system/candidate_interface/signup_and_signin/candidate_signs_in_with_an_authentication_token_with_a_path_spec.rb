require 'rails_helper'

RSpec.feature 'Candidates authenitcation token has the path attriute populated' do
  include SignInHelper
  include CandidateHelper

  scenario 'Candidate is redirected to the appropriate page' do
    given_the_pilot_is_open
    and_i_am_a_candidate_with_an_account
    and_i_have_received_a_token_associated_with_the_personal_statment_path

    when_i_sign_in_using_the_token
    and_i_confirm_the_sign_in
    then_i_receive_am_redirected_to_the_personal_statement_page

    given_i_am_signed_out
    and_i_have_an_expired_token_associated_with_the_personal_statment_path

    when_i_sign_in_using_the_token
    and_i_request_a_new_link
    then_i_receive_an_email_inviting_me_to_sign_in

    when_i_click_on_the_link_in_my_email
    and_i_confirm_the_sign_in
    then_i_receive_am_redirected_to_the_personal_statement_page
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_i_am_a_candidate_with_an_account
    create_and_sign_in_candidate
    @candidate = current_candidate
  end

  def and_i_have_received_a_token_associated_with_the_personal_statment_path
    @magic_link_token = MagicLinkToken.new
    create(
      :authentication_token,
      user: @candidate,
      hashed_token: @magic_link_token.encrypted,
      path: 'candidate_interface_edit_becoming_a_teacher_path',
    )
  end

  def when_i_sign_in_using_the_token
    visit candidate_interface_authenticate_path(token: @magic_link_token.raw)
  end

  def and_i_confirm_the_sign_in
    confirm_sign_in
  end

  def then_i_receive_am_redirected_to_the_personal_statement_page
    expect(page).to have_current_path candidate_interface_edit_becoming_a_teacher_path
  end

  def given_i_am_signed_out
    click_link 'Sign out'
  end

  def and_i_have_an_expired_token_associated_with_the_personal_statment_path
    @magic_link_token = MagicLinkToken.new
    create(
      :authentication_token,
      user: @candidate,
      hashed_token: @magic_link_token.encrypted,
      path: 'candidate_interface_edit_becoming_a_teacher_path',
      created_at: 2.hours.ago,
    )
  end

  def and_i_request_a_new_link
    click_button 'Email me a new link'
  end

  def when_i_click_on_the_link_in_my_email
    click_magic_link_in_email
  end

  def then_i_receive_an_email_inviting_me_to_sign_in
    open_email(@candidate.email_address)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end
end
