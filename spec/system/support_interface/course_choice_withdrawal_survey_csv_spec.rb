require 'rails_helper'

RSpec.feature 'Course choice withdrawal survey CSV' do
  include DfESignInHelpers

  scenario 'support user can download a CSV with the course choice withdrawal survey results' do
    given_i_am_a_support_user

    when_i_visit_the_service_performance_page
    and_i_click_on_download_course_choice_withdrawl_survey_results
    then_i_should_be_informed_there_are_no_survey_results

    given_there_are_candidate_survey_results

    when_i_visit_the_service_performance_page
    and_i_click_on_download_course_choice_withdrawl_survey_results
    then_i_should_be_able_to_download_a_csv
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_service_performance_page
    visit support_interface_performance_path
  end

  def and_i_click_on_download_course_choice_withdrawl_survey_results
    click_link 'Download course choice withdrawal survey results (CSV)'
  end

  def then_i_should_be_informed_there_are_no_survey_results
    expect(page).to have_content('No candidates have filled in the survey')
  end

  def given_there_are_candidate_survey_results
    create_list(:application_choice, 3, :withdrawn, :with_survey_completed)
  end

  def then_i_should_be_able_to_download_a_csv
    expect(page).to have_content ApplicationChoice.first.application_form.full_name
    expect(page).to have_content ApplicationChoice.second.application_form.full_name
    expect(page).to have_content ApplicationChoice.third.application_form.full_name
  end
end
