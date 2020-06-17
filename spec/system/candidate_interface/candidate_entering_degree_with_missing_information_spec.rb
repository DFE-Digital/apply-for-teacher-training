require 'rails_helper'

RSpec.feature 'Entering degree with missing info' do
  include CandidateHelper

  scenario 'Candidate attempts to submit an incomplete degree' do
    given_i_am_viewing_my_application_form
    when_i_click_on_degree
    then_i_see_the_undergraduate_degree_form

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

  def when_i_submit_a_degree_type
    fill_in 'Type of degree', with: 'BSc'
    click_button t('application_form.degree.base.button')
  end

  def and_manually_skip_ahead_to_the_review_page
    visit candidate_interface_degrees_review_path
  end

  def then_i_cannot_mark_this_section_complete
    check t('application_form.degree.review.completed_checkbox')
    click_button t('application_form.degree.review.button')
    expect(page).to have_content 'You can’t mark this section complete with incomplete degree information.'
    expect(current_candidate.current_application).not_to be_degrees_completed
  end
end
