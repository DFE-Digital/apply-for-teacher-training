require 'rails_helper'

RSpec.feature 'Candidate submit the application' do
  include CandidateHelper

  scenario 'Candidate with personal details' do
    given_i_am_signed_in
    and_i_filled_in_personal_details_and_review_my_application
    and_i_confirm_my_application

    then_i_can_submit_the_application

    and_i_can_see_my_application_has_been_successfully_submitted
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application successfully submitted'
  end

  def then_i_can_submit_the_application
    click_button'Submit application'
  end

  def and_i_confirm_my_application
    click_link 'Continue'
  end

  def and_i_filled_in_personal_details_and_review_my_application
    and_i_filled_in_personal_details
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def then_i_can_review_my_application
    expect(page).to have_content 'Review your application'
  end

  def then_i_can_see_my_personal_details
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '6 April 1937'
    expect(page).to have_content 'British and American'
    expect(page).to have_content "I'm great at Galactic Basic so English is a piece of cake"
  end

  def when_i_click_on_check_your_answers
    click_link 'Check your answers before submitting'
  end

  def and_i_filled_in_personal_details
    visit candidate_interface_personal_details_edit_path
    candidate_fills_in_personal_details(scope: 'application_form.personal_details')

    click_button t('complete_form_button', scope: 'application_form.personal_details')
  end
end
