require 'rails_helper'

RSpec.describe 'Candidate needs to provide 2 new referees' do
  include CandidateHelper

  scenario "Candidate provides a new referee because 2 didn't respond" do
    FeatureFlag.activate('pilot_open')
    FeatureFlag.activate('replacement_referee_with_referee_type')

    given_i_am_signed_in_as_a_candidate
    and_i_have_submitted_my_application
    and_both_of_my_referees_havent_responded_within_a_reasonable_timeframe

    when_i_visit_the_application_dashboard
    then_i_see_that_i_need_new_references

    when_i_visit_the_start_page
    then_i_see_the_interstitial_page_to_add_new_referees

    when_i_click_to_add_a_new_referee
    then_i_am_asked_to_specify_the_type_of_my_first_new_reference

    when_i_click_continue
    then_i_see_an_error_to_choose_the_type_of_my_first_reference

    when_i_choose_school_based_as_reference_type
    and_i_click_continue
    then_i_am_asked_for_the_details_of_my_school_based_referee

    when_i_fill_in_the_form
    then_i_am_asked_to_specify_the_type_of_my_second_new_reference

    when_i_choose_academic_as_reference_type
    and_i_click_continue
    then_i_am_asked_for_the_details_of_my_academic_referee

    when_i_fill_in_the_second_form
    then_i_see_the_reference_review_page

    when_i_click_to_edit_the_referee_type
    and_i_choose_character_as_reference_type
    and_i_click_continue
    then_i_can_see_the_updated_reference_type

    when_i_click_to_edit_the_referee
    and_i_edit_the_name
    then_i_see_the_updated_name_on_the_confirm_page

    when_i_click_to_confirm
    then_the_new_referees_should_receive_emails
    and_i_see_that_my_new_references_have_been_requested
    and_i_should_not_be_asked_to_provide_another_reference

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

  def and_both_of_my_referees_havent_responded_within_a_reasonable_timeframe
    create(:reference, :requested, application_form: @application_form, requested_at: Time.zone.now - 30.days)
    create(:reference, :requested, application_form: @application_form, requested_at: Time.zone.now - 30.days)
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_see_that_i_need_new_references
    expect(page).to have_content 'You need to give details of 2 new referees'
  end

  def when_i_visit_the_start_page
    visit candidate_interface_interstitial_path
  end

  def then_i_see_the_interstitial_page_to_add_new_referees
    expect(page).to have_content 'You need to add 2 new referees'
    @application_form.application_references.each do |referee|
      expect(page).to have_content "#{referee.name} did not respond to our request"
    end
  end

  def when_i_click_to_add_a_new_referee
    click_on 'Add new referees'
  end

  def then_i_am_asked_to_specify_the_type_of_my_first_new_reference
    expect(page).to have_content('Add your first new referee')
    expect(page).to have_content('What kind of reference are you adding?')
  end

  def when_i_click_continue
    click_button 'Continue'
  end

  def then_i_see_an_error_to_choose_the_type_of_my_first_reference
    expect(page).to have_content('Choose the type of your reference')
  end

  def when_i_choose_school_based_as_reference_type
    choose 'School-based'
  end

  def and_i_click_continue
    click_button 'Continue'
  end

  def then_i_am_asked_for_the_details_of_my_school_based_referee
    expect(page).to have_content('Details of your new school-based referee')
  end

  def when_i_fill_in_the_form
    fill_in 'Full name', with: 'AO Reference'
    fill_in 'Email address', with: 'betty@example.com'
    fill_in 'What is your relationship to this referee and how long have you known them?', with: 'Just somebody I used to know'
    click_button 'Continue'
  end

  def then_i_am_asked_to_specify_the_type_of_my_second_new_reference
    expect(page).to have_content('Add your second new referee')
    expect(page).to have_content('What kind of reference are you adding?')
  end

  def when_i_choose_academic_as_reference_type
    choose 'Academic'
  end

  def then_i_am_asked_for_the_details_of_my_academic_referee
    expect(page).to have_content('Details of your new academic referee')
  end

  def when_i_fill_in_the_second_form
    fill_in 'Full name', with: 'Second Reference'
    fill_in 'Email address', with: 'boppie@example.com'
    fill_in 'What is your relationship to this referee and how long have you known them?', with: 'Just somebody I used to know'
    click_button 'Continue'
  end

  def then_i_see_the_reference_review_page
    expect(page).to have_content 'AO Reference'
    expect(page).to have_content 'betty@example.com'
    expect(page).to have_content 'School-based'

    expect(page).to have_content 'Second Reference'
    expect(page).to have_content 'boppie@example.com'
    expect(page).to have_content 'Academic'
  end

  def when_i_click_to_edit_the_referee_type
    click_on 'Change reference type for AO Reference'
  end

  def and_i_choose_character_as_reference_type
    choose 'Character'
  end

  def then_i_can_see_the_updated_reference_type
    expect(page).to have_content 'Character'
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

    expect(page).to have_content 'Second Reference'
    expect(page).to have_content 'boppie@example.com'
  end

  def when_i_click_to_confirm
    click_on 'Confirm new referees'
  end

  def then_the_new_referees_should_receive_emails
    open_email('betty@example.com')
    expect(current_email.subject).to have_content('Give a reference to support the teacher training application of')

    open_email('boppie@example.com')
    expect(current_email.subject).to have_content('Give a reference to support the teacher training application of')
  end

  def and_i_see_that_my_new_references_have_been_requested
    expect(page).to have_content 'Thank you. We’ve asked each new referee for a reference'
  end

  def and_i_should_not_be_asked_to_provide_another_reference
    expect(page).not_to have_content 'You need to give details of a new referee'
  end

  def when_i_go_back_to_the_edit_page
    visit @edit_page_url
  end

  def then_i_see_a_404_page
    expect(page).to have_content 'Page not found'
  end
end
