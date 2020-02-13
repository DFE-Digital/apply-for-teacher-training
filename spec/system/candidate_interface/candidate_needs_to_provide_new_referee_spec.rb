require 'rails_helper'

RSpec.describe 'Candidate needs to provide a new referee' do
  include CandidateHelper

  scenario "Candidate provides a new referee because one didn't respond" do
    FeatureFlag.activate('pilot_open')
    FeatureFlag.activate('show_new_referee_needed')

    given_i_am_signed_in_as_a_candidate
    and_i_have_submitted_my_application
    and_one_of_my_referees_hasnt_responded_within_a_reasonable_timeframe

    when_i_sign_in
    then_i_see_the_interstitial_page_to_add_new_referee

    when_i_choose_to_continue_without_adding_a_new_referee
    then_i_see_that_i_need_a_new_reference_on_the_dashboard

    when_i_sign_in_again
    then_i_see_the_interstitial_page_to_add_new_referee

    when_i_click_to_add_a_new_referee
    and_i_fill_in_the_form
    then_i_see_the_reference_review_page

    when_i_click_to_edit_the_referee
    and_i_edit_the_name
    then_i_see_the_updated_name_on_the_confirm_page

    when_i_click_to_confirm
    then_the_new_referee_should_receive_an_email
    and_i_see_that_my_new_references_have_been_requested
    and_i_should_not_be_asked_to_provide_another_reference

    when_i_sign_in_again
    then_i_should_not_be_asked_to_provide_another_reference

    when_i_go_back_to_the_edit_page
    then_i_see_a_404_page
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_submitted_my_application
    @application_form = create(:completed_application_form, candidate: @candidate)
  end

  def and_one_of_my_referees_hasnt_responded_within_a_reasonable_timeframe
    create(:reference, :complete, application_form: @application_form, requested_at: Time.zone.now - 30.days)
    @late_referee = create(:reference, :requested, application_form: @application_form, requested_at: Time.zone.now - 30.days)
  end

  def when_i_sign_in
    visit candidate_interface_interstitial_path
  end

  def when_i_sign_in_again
    when_i_sign_in
  end

  def then_i_see_that_i_need_a_new_reference_on_the_dashboard
    expect(page).to have_content 'You need to give details of a new referee'
  end

  def then_i_see_the_interstitial_page_to_add_new_referee
    expect(page).to have_content 'You need to add a new referee'
    expect(page).to have_content "#{@late_referee.name} did not respond to our request."
  end

  def when_i_choose_to_continue_without_adding_a_new_referee
    click_on 'Continue without adding a new referee'
  end

  def when_i_click_to_add_a_new_referee
    click_on 'Add a new referee'
  end

  def and_i_fill_in_the_form
    expect(page).to have_title 'Add a new referee'

    fill_in 'Full name', with: 'AO Reference'
    fill_in 'Email address', with: 'betty@example.com'
    fill_in 'What is your relationship to this referee and how long have you known them?', with: 'Just somebody I used to know'
    click_button 'Continue'
  end

  def then_i_see_the_reference_review_page
    expect(page).to have_content 'AO Reference'
    expect(page).to have_content 'betty@example.com'
  end

  def when_i_click_to_edit_the_referee
    click_on 'Change name for AO Reference'
  end

  def and_i_edit_the_name
    @edit_page_url = page.current_url
    fill_in 'Full name', with: 'A.O. Reference'
    click_button 'Continue'
  end

  def then_i_see_the_updated_name_on_the_confirm_page
    expect(page).to have_content 'A.O. Reference'
    expect(page).to have_content 'betty@example.com'
  end

  def when_i_click_to_confirm
    click_on 'Confirm new referee'
  end

  def then_the_new_referee_should_receive_an_email
    open_email('betty@example.com')

    expect(current_email.subject).to have_content('Give a reference to support the teacher training application of')
  end

  def and_i_see_that_my_new_references_have_been_requested
    expect(page).to have_content 'Thank you. We’ve asked your new referee for a reference'
  end

  def and_i_should_not_be_asked_to_provide_another_reference
    expect(page).not_to have_content 'You need to give details of a new referee'
  end

  def then_i_should_not_be_asked_to_provide_another_reference
    and_i_should_not_be_asked_to_provide_another_reference
  end

  def when_i_go_back_to_the_edit_page
    visit @edit_page_url
  end

  def then_i_see_a_404_page
    expect(page).to have_content 'Page not found'
  end
end
