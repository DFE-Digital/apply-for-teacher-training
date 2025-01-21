require 'rails_helper'

RSpec.describe 'Candidates authentication token has the path attribute populated', time: CycleTimetableHelper.mid_cycle do
  include SignInHelper
  include CandidateHelper

  it 'Candidate is redirected to the appropriate page' do
    given_i_am_a_candidate_with_an_account
    and_i_have_received_a_token_associated_with_the_personal_statement_path

    when_i_sign_in_using_the_token
    and_i_confirm_the_sign_in
    then_i_am_redirected_to_the_personal_statement_page

    given_i_am_signed_out
    and_i_have_an_expired_token_associated_with_the_personal_statement_path

    when_i_sign_in_using_the_token
    and_i_click_the_button_to_sign_in
    and_i_submit_my_email_address
    then_i_receive_an_email_inviting_me_to_sign_in

    when_i_click_on_the_link_in_my_email
    and_i_confirm_the_sign_in
    then_i_am_redirected_to_the_personal_statement_page

    given_i_have_a_reference_in_the_not_requested_yet_state
    and_i_have_received_a_token_associated_with_the_review_reference_path

    when_i_sign_in_using_the_token
    and_i_confirm_the_sign_in
    then_i_am_redirected_to_the_review_reference_page
  end

  def given_i_am_a_candidate_with_an_account
    create_and_sign_in_candidate
    @candidate = current_candidate
  end

  def and_i_have_received_a_token_associated_with_the_personal_statement_path
    @magic_link_token = MagicLinkToken.new
    create(
      :authentication_token,
      user: @candidate,
      hashed_token: @magic_link_token.encrypted,
      path: '/candidate/application/personal-statement',
    )
  end

  def when_i_sign_in_using_the_token
    visit candidate_interface_authenticate_path(token: @magic_link_token.raw)
  end

  def and_i_confirm_the_sign_in
    confirm_sign_in
  end

  def then_i_am_redirected_to_the_personal_statement_page
    expect(page).to have_current_path candidate_interface_new_becoming_a_teacher_path
  end

  def given_i_am_signed_out
    click_link_or_button 'Sign out'
  end

  def and_i_have_an_expired_token_associated_with_the_personal_statement_path
    @magic_link_token = MagicLinkToken.new
    create(
      :authentication_token,
      user: @candidate,
      hashed_token: @magic_link_token.encrypted,
      path: '/candidate/application/personal-statement',
      created_at: 2.hours.ago,
    )
  end

  def and_i_click_the_button_to_sign_in
    click_link_or_button 'Sign in'
  end

  def and_i_submit_my_email_address
    fill_in 'Email address', with: @candidate.email_address
    click_link_or_button 'Continue'
  end

  def when_i_click_on_the_link_in_my_email
    click_magic_link_in_email
  end

  def then_i_receive_an_email_inviting_me_to_sign_in
    open_email(@candidate.email_address)
    expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
  end

  def given_i_have_a_reference_in_the_not_requested_yet_state
    @reference = create(:reference, :not_requested_yet, application_form: @candidate.current_application)
  end

  def and_i_have_received_a_token_associated_with_the_review_reference_path
    @magic_link_token = MagicLinkToken.new
    create(
      :authentication_token,
      user: @candidate,
      hashed_token: @magic_link_token.encrypted,
      path: candidate_interface_references_review_path,
    )
  end

  def then_i_am_redirected_to_the_review_reference_page
    expect(page).to have_current_path(candidate_interface_references_review_path)
  end
end
