require 'rails_helper'

RSpec.feature 'Service performance' do
  include DfESignInHelpers

  scenario 'View service statistics' do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system

    when_i_visit_the_performance_page_in_support
    and_i_click_on_the_performance_dashboard_link

    then_i_should_see_the_total_count_of_candidates
    and_i_should_see_the_total_count_of_application_forms
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    create_list(:application_form, 3)
    create(:candidate)
  end

  def when_i_visit_the_performance_page_in_support
    visit support_interface_performance_path
  end

  def and_i_click_on_the_performance_dashboard_link
    click_on 'Service performance'
  end

  def then_i_should_see_the_total_count_of_candidates
    within '#candidate-count' do
      expect(page).to have_content '4'
    end
  end

  def and_i_should_see_the_total_count_of_application_forms
    within '#application-form-count' do
      expect(page).to have_content '3'
    end
  end
end
