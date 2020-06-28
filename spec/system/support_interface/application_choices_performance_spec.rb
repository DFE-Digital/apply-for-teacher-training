require 'rails_helper'

RSpec.feature 'Candidate journey tracking CSV' do
  include DfESignInHelpers

  scenario 'support user can download a CSV with the candidate journey tracking report' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system

    when_i_visit_the_service_performance_page
    and_i_click_on_download_candidate_journey_tracking_report
    then_i_should_be_able_to_download_a_csv
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_applications_in_the_system
    create(:application_choice, :awaiting_provider_decision)
  end

  def when_i_visit_the_service_performance_page
    visit support_interface_performance_path
  end

  def and_i_click_on_download_candidate_journey_tracking_report
    click_link 'Download candidate journey tracking (CSV)'
  end

  def then_i_should_be_able_to_download_a_csv
    pending 'not implemented yet'
  end
end
