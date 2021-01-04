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
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_i_am_a_candidate_with_an_account
    create_and_sign_in_candidate
  end

  def and_i_have_received_a_token_associated_with_the_personal_statment_path
    @magic_link_token = MagicLinkToken.new
    create(:authentication_token, user: current_candidate, hashed_token: @magic_link_token.encrypted, path: 'candidate_interface_edit_becoming_a_teacher_path')
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
end
