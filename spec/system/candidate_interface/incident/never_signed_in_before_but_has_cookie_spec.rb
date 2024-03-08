require 'rails_helper'
require_relative 'incident_helper'

RSpec.feature 'Incident account protection' do
  include SignInHelper
  include CandidateHelper
  include IncidentHelper

  scenario 'The candidate cookie is rejected', time: Time.zone.local(2024, 3, 4) do
    given_i_am_a_candidate_with_a_rejected_id
    and_i_never_signed_in_before

    # This happens on the Ghost DB
    when_i_am_signed_in
    and_i_visit_my_details
    then_i_am_logged_out_and_redirected_to_create_an_account

    # 11/3/2024
    when_one_week_passes
    and_i_visit_my_details
    then_i_am_logged_out_and_redirected_to_sign_in

    and_i_create_an_account
    and_i_visit_my_details
    then_i_am_on_the_my_details_page
  end

  def and_i_never_signed_in_before
    @candidate.update(last_signed_in_at: nil)
  end

  def and_i_create_an_account
    visit root_path
    choose 'Yes, sign in'
    fill_in 'Email', with: @candidate.email_address
    click_link_or_button t('continue')

    open_email(@candidate.email_address)
    click_magic_link_in_email
    confirm_create_account
    login_as(@candidate) # Make sure is logged in from warden
  end

  def click_magic_link_in_email
    current_email.find_css('a').first.click
  end

  def confirm_create_account
    expect(page).to have_content 'Create an account to apply for teacher training'
    click_link_or_button 'Create account'
  end
end
