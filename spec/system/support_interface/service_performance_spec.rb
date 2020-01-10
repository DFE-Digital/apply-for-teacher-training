require 'rails_helper'

RSpec.feature 'Service performance' do
  scenario 'View service statistics' do
    given_there_are_candidates_in_the_system

    when_i_visit_the_service_performance_page
    then_i_should_see_the_total_count_of_candidates
  end

  def given_there_are_candidates_in_the_system
    create_list(:candidate, 2)
  end

  def when_i_visit_the_service_performance_page
    visit support_interface_performance_path
  end

  def then_i_should_see_the_total_count_of_candidates
    within '#total-sign-ups' do
      expect(page).to have_content '2'
    end
  end
end
