require 'rails_helper'

RSpec.feature 'Entering their degrees' do
  include CandidateHelper

  scenario 'Candidate enters a degree with a predicted grade' do
    given_i_am_signed_in
    when_i_add_a_degree_that_is_not_finished_yet
    then_i_can_review_the_details_of_this_degree
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_add_a_degree_that_is_not_finished_yet
    visit candidate_interface_application_form_path
    click_link 'Degree'
    choose 'UK degree'
    fill_in 'Type of degree', with: 'Bachelor of Arts'
    click_on_save_and_continue

    fill_in 'What subject is your degree?', with: 'Fashion'
    click_on_save_and_continue

    fill_in 'Which institution did you study at?', with: 'Royal College of Art'
    click_on_save_and_continue

    expect(page).to have_content('Have you completed your degree?')
    choose 'No'
    click_on_save_and_continue

    expect(page).to have_content('What grade do you think you’ll get?')
    expect(page).to have_content('You must give an academic referee who can agree that you’re aiming for this grade.')
    choose 'Third-class honours'
    click_on_save_and_continue

    fill_in 'Year started course', with: RecruitmentCycle.current_year - 3
    click_on_save_and_continue

    fill_in 'Graduation year', with: RecruitmentCycle.previous_year
    click_on_save_and_continue
    expect(page).to have_content('Enter a year that is in the future')

    fill_in 'Graduation year', with: RecruitmentCycle.current_year
    click_on_save_and_continue
  end

  def then_i_can_review_the_details_of_this_degree
    expect(page).to have_content 'BA (Hons) Fashion'
    expect(page).to have_content 'Royal College of Art'

    completion_status_row = page.all('.govuk-summary-list__row').find { |r| r.has_link? 'Change completion status' }
    predicted_grade_row = page.all('.govuk-summary-list__row').find { |r| r.has_link? 'Change grade' }

    expect(completion_status_row).to have_content 'Have you completed this degree?'
    expect(completion_status_row).to have_content 'No'
    expect(predicted_grade_row).to have_content 'Predicted grade'
    expect(predicted_grade_row).to have_content 'Third-class honours'
  end

private

  def click_on_save_and_continue
    click_button t('save_and_continue')
  end
end
