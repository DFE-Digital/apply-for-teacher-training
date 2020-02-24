require 'rails_helper'

RSpec.feature 'Service performance' do
  scenario 'Refree survey csv' do
    given_there_are_referee_survey_results

    when_i_visit_the_service_performance_page
    and_i_click_on_download_referee_survey_results
    then_i_should_download_a_csv
    and_it_should_have
  end

  def given_there_are_candidates_and_application_forms_in_the_system
    create_list(:application_reference, 3, :complete)
  end

  def when_i_visit_the_service_performance_page
    visit integrations_performance_path
  end

  def and_i_click_on_download_referee_survey_results
    click_link 'Download referee survey results (CSV)'
  end

  def then_i_should_download_a_csv
    binding.pry
   #  get :index, format: :csv
   #  assert_response :success
   # assert_equal "text/csv", response.content_type
   #
   # csv = CSV.parse response.body # Let raise if invalid CSV
   # assert csv
   # assert_equal 6, csv.size
  end
end
