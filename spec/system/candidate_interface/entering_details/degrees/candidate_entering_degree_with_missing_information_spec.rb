require 'rails_helper'

RSpec.feature 'Entering degree with missing info' do
  include CandidateHelper

  scenario 'Candidate attempts to submit an incomplete degree' do
    given_i_am_viewing_my_application_form
    when_i_click_on_degree
    then_i_see_the_undergraduate_degree_form

    when_i_submit_without_selecting_a_degree_type
    then_i_see_a_validation_error

    when_i_submit_a_degree_type
    and_manually_skip_ahead_to_the_review_page
    then_i_cannot_mark_this_section_complete
  end

  def given_i_am_viewing_my_application_form
    create_and_sign_in_candidate
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_degree
    click_link 'Degree'
  end

  def then_i_see_the_undergraduate_degree_form
    expect(page).to have_content 'Add undergraduate degree'
  end

  def when_i_submit_without_selecting_a_degree_type
    click_button t('save_and_continue')
  end

  def then_i_see_a_validation_error
    expect(page).to have_content 'Select if this is a UK degree or not'
    expect(page).not_to have_content 'Enter your degree type'
  end

  def when_i_submit_a_degree_type
    choose 'UK degree'
    fill_in 'Type of degree', with: 'BSc'
    click_button t('save_and_continue')
  end

  def and_manually_skip_ahead_to_the_review_page
    visit candidate_interface_degrees_review_path
  end

  def then_i_cannot_mark_this_section_complete
    choose t('application_form.completed_radio')
    click_button t('continue')
    expect(page).to have_content 'You cannot mark this section complete with incomplete degree information.'
    expect(current_candidate.current_application).not_to be_degrees_completed
  end
end
