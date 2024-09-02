require 'rails_helper'

RSpec.describe 'A candidate can not edit some personal details after first submission' do
  include SignInHelper
  include CandidateHelper

  before do
    create_and_sign_in_candidate
  end

  scenario 'candidate can not edit personal details after submission' do
    given_i_already_have_one_completed_application
    and_i_visit_the_personal_details_page

    then_i_can_edit_the_nationality
    and_i_can_edit_the_right_to_work
    and_i_can_edit_the_immigration_status

    when_i_submit_my_application
    and_i_visit_the_personal_details_page

    then_i_cant_edit_the_nationality
    and_i_cant_edit_the_right_to_work
    and_i_cant_edit_the_immigration_status

    when_i_try_to_visit_the_nationality_page
    then_i_am_redirected_to_your_details_page

    when_i_try_to_visit_the_right_to_work_page
    then_i_am_redirected_to_your_details_page

    when_i_try_to_visit_the_immigration_status_page
    then_i_am_redirected_to_your_details_page
  end

  def given_i_already_have_one_completed_application
    create(
      :application_form,
      :completed,
      first_nationality: 'Albanian',
      right_to_work_or_study: 'yes',
      candidate: current_candidate,
    )
  end

  def when_i_submit_my_application
    create(:application_choice, :awaiting_provider_decision, application_form: ApplicationForm.first)
  end
end

def and_i_visit_the_personal_details_page
  visit candidate_interface_personal_details_show_path
end

def then_i_can_edit_the_nationality
  expect(page).to have_content('Change nationality')
end

def and_i_can_edit_the_right_to_work
  expect(page).to have_content('Change if you have the right to work or study in the UK')
end

def and_i_can_edit_the_immigration_status
  expect(page).to have_content('Change visa or immigration status')
end

def then_i_cant_edit_the_nationality
  expect(page).to have_no_content('Change nationality')
end

def and_i_cant_edit_the_right_to_work
  expect(page).to have_no_content('Change if you have the right to work or study in the UK')
end

def and_i_cant_edit_the_immigration_status
  expect(page).to have_no_content('Change immigration status')
end

def when_i_try_to_visit_the_nationality_page
  visit candidate_interface_nationalities_path
end

def when_i_try_to_visit_the_right_to_work_page
  visit candidate_interface_immigration_right_to_work_path
end

def when_i_try_to_visit_the_immigration_status_page
  visit candidate_interface_immigration_status_path
end

def then_i_am_redirected_to_your_details_page
  expect(page).to have_current_path candidate_interface_details_path
end
