require 'rails_helper'

RSpec.describe 'Creating references with personal email addresses after an offer has been accepted' do
  include CandidateHelper

  scenario 'Candidate adds a new reference and see personal email address interruption' do
    given_i_am_signed_in
    and_i_have_an_accepted_offer
    and_i_navigate_to_add_another_reference
    and_i_complete_some_reference_details

    when_i_provide_an_email_that_appears_to_be_personal
    then_i_see_the_interruption

    when_i_click_go_back_and_change
    and_i_provide_a_work_email_address
    then_i_see_the_relationship_page_not_the_interruption

    when_i_complete_my_references_details
    then_i_see_my_reference_with_professional_email_address
  end

  scenario 'Candidate saves a new reference and with personal email address' do
    given_i_am_signed_in
    and_i_have_an_accepted_offer
    and_i_navigate_to_add_another_reference
    and_i_complete_some_reference_details
    when_i_provide_an_email_that_appears_to_be_personal
    then_i_see_the_interruption

    when_i_choose_to_continue_with_the_personal_email_address
    then_i_see_the_relationship_page_not_the_interruption

    when_i_complete_my_references_details
    then_i_see_my_reference_with_personal_email_address
  end

  scenario 'Candidate changes personal email address at interruption with back buttons' do
    given_i_am_signed_in
    and_i_have_an_accepted_offer
    and_i_navigate_to_add_another_reference
    and_i_complete_some_reference_details
    when_i_provide_an_email_that_appears_to_be_personal
    then_i_see_the_interruption

    when_i_click_back
    and_i_provide_a_work_email_address
    then_i_see_the_relationship_page_not_the_interruption

    when_i_complete_my_references_details
    then_i_see_my_reference_with_professional_email_address
  end

  scenario 'Candidate uses personal email address for a character reference' do
    given_i_am_signed_in
    and_i_have_an_accepted_offer
    and_i_navigate_to_add_another_reference
    and_i_complete_some_reference_details_for_a_character_reference
    when_i_provide_an_email_that_appears_to_be_personal
    then_i_see_the_relationship_page_not_the_interruption
    when_i_complete_my_references_details
    then_i_see_my_character_reference_with_personal_email
  end

private

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @application_form = create(:completed_application_form, candidate: @current_candidate)
  end

  def and_i_have_an_accepted_offer
    @application_form = create(:completed_application_form, candidate: @current_candidate)
    @pending_reference = create(:reference, :feedback_requested, reminder_sent_at: nil, application_form: @application_form)
    @completed_reference = create(:reference, :feedback_provided, application_form: @application_form)

    @application_choice = create(
      :application_choice,
      :accepted,
      application_form: @application_form,
    )
  end

  def and_i_navigate_to_add_another_reference
    visit candidate_interface_application_offer_dashboard_path
    click_on 'Request another reference'
    click_on 'Continue'
  end

  def and_i_complete_some_reference_details
    choose 'Academic, such as a university tutor'
    click_on 'Continue'
    fill_in 'What’s the name of the person who can give a reference?', with: 'Walter White'
    click_on 'Save and continue'
  end

  def and_i_complete_some_reference_details_for_a_character_reference
    choose 'Character, such as a mentor or someone you know from volunteering'
    click_on 'Continue'
    fill_in 'What’s the name of the person who can give a reference?', with: 'Walter White'
    click_on 'Save and continue'
  end

  def when_i_click_add_reference
    click_on 'Add reference'
  end

  def when_i_provide_an_email_that_appears_to_be_personal
    expect(page).to have_content 'Enter their professional email address if you know it. Many providers will not accept references that come from a personal email address'
    fill_in 'What is Walter White’s email address?', with: 'walter.white@gmail.com'
    click_on 'Save and continue'
  end

  def and_i_provide_a_work_email_address
    expect(page).to have_content 'Enter their professional email address if you know it. Many providers will not accept references that come from a personal email address'
    fill_in 'What is Walter White’s email address?', with: 'walter.white@open.ac.uk'
  end

  def when_i_click_go_back_and_change
    click_on 'Go back and change the email address'
  end
  alias_method :when_i_click_back, :when_i_click_go_back_and_change

  def then_i_see_the_interruption
    expect(page).to have_content 'walter.white@gmail.com looks like a personal email address'
    expect(page).to have_content 'You should ask Walter White if they have a work email address you can use instead and update your application.'
  end

  def then_i_see_the_relationship_page_not_the_interruption
    expect(page).to have_current_path candidate_interface_request_reference_references_relationship_path(@application_form.application_references.creation_order.last.id)
    expect(page).to have_content 'How do you know Walter White and how long have you known them?'
    expect(page).to have_no_content 'You should ask Walter White if they have a work email address you can use instead and update your application.'
  end

  def when_i_choose_to_continue_with_the_personal_email_address
    click_on 'Save and continue'
  end

  def when_i_complete_my_references_details
    fill_in 'How do you know Walter White and how long have you known them?', with: 'They were my course supervisor.'
    click_on 'Save and continue'
  end

  def and_i_provide_a_work_email_address
    expect(page).to have_content 'Enter their professional email address if you know it. Many providers will not accept references that come from a personal email address.'
    fill_in 'What is Walter White’s email address?', with: 'walter.white@open.ac.uk'
    click_on 'Save and continue'
  end

  def then_i_see_my_reference_with_professional_email_address
    expect(page).to have_content('Academic, such as a university tutor')
    expect(page).to have_content('Walter White')
    expect(page).to have_content('walter.white@open.ac.uk')
    expect(page).to have_content('They were my course supervisor.')
  end

  def then_i_see_my_reference_with_personal_email_address
    expect(page).to have_content('Academic, such as a university tutor')
    expect(page).to have_content('Walter White')
    expect(page).to have_content('walter.white@gmail.com')
    expect(page).to have_content('They were my course supervisor.')
  end

  def then_i_see_my_character_reference_with_personal_email
    expect(page).to have_content('Character, such as a mentor or someone you know from volunteering')
    expect(page).to have_content('Walter White')
    expect(page).to have_content('walter.white@gmail.com')
    expect(page).to have_content('They were my course supervisor.')
  end

  def and_i_click_request_another_reference
    click_on 'Request another reference'
  end
end
