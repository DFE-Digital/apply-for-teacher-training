require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly' do
  include CandidateHelper

  scenario 'Candidate reviews completed application and updates personal details section' do
    given_i_am_signed_in
    when_i_have_completed_my_application
    and_i_review_my_application
    then_i_should_see_all_sections_are_complete

    when_i_click_change_on_why_i_want_to_become_a_teacher
    then_i_should_see_the_becoming_a_teacher_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_why_i_want_to_become_a_teacher
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_my_updated_becoming_a_teacher_response
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
    @current_candidate.current_application.application_references.each do |reference|
      reference.update!(feedback_status: :feedback_provided)
    end
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_all_sections_are_complete
    application_form_sections.each do |section|
      expect(page).not_to have_selector "[data-qa='incomplete-#{section}']"
    end
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def when_i_click_change_on_why_i_want_to_become_a_teacher
    within('[data-qa="becoming-a-teacher"]') do
      click_link 'Change'
    end
  end

  def then_i_should_see_the_becoming_a_teacher_form
    expect(page).to have_current_path(candidate_interface_edit_becoming_a_teacher_path('return-to' => 'application-review'))
  end

  def when_i_click_back
    click_link 'Back'
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def when_i_update_why_i_want_to_become_a_teacher
    when_i_click_change_on_why_i_want_to_become_a_teacher
    fill_in 'Why do you want to be a teacher?', with: 'All the dev jobs were taken.'
    click_button 'Continue'
  end

  def and_i_should_see_my_updated_becoming_a_teacher_response
    within('[data-qa="becoming-a-teacher"]') do
      expect(page).to have_content('All the dev jobs were taken.')
    end
  end
end
