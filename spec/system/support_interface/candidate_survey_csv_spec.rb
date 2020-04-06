require 'rails_helper'

RSpec.feature 'Candidate survey CSV' do
  include DfESignInHelpers

  scenario 'support user can download a CSV with the candidate satisfaction survey results' do
    given_i_am_a_support_user
    and_there_are_candidate_survey_results

    when_i_visit_the_service_performance_page
    and_i_click_on_download_candidate_survey_results
    then_i_should_be_able_to_download_a_csv
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidate_survey_results
    create_list(:completed_application_form, 3, :with_survey_completed)
  end

  def when_i_visit_the_service_performance_page
    visit support_interface_performance_path
  end

  def and_i_click_on_download_candidate_survey_results
    click_link 'Download candidate satisfcation survey results (CSV)'
  end

  def then_i_should_be_able_to_download_a_csv
    expect(page).to have_content ApplicationForm.first.full_name
    expect(page).to have_content ApplicationForm.second.full_name
    expect(page).to have_content ApplicationForm.third.full_name
  end
end
