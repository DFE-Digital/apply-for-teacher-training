require 'rails_helper'

RSpec.feature 'Service performance' do
  include DfESignInHelpers

  scenario 'View service statistics' do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system

    when_i_visit_the_performance_dashboard_in_support

    then_i_should_see_the_total_count_of_candidates
    and_i_should_see_the_total_count_of_application_forms

    when_there_are_candidates_that_have_never_signed_in
    and_i_visit_the_performance_dashboard_in_support

    then_i_see_the_total_number_of_candidates_that_have_not_signed_in

    when_i_go_a_report_for_a_specific_year

    then_i_only_see_candidates_that_have_signed_in
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    create_list(:application_form, 3)
  end

  def when_there_are_candidates_that_have_never_signed_in
    create_list(:candidate, 2)
  end

  def when_i_visit_the_performance_dashboard_in_support
    visit support_interface_performance_path
    click_on 'Service performance'
  end

  alias_method :and_i_visit_the_performance_dashboard_in_support, :when_i_visit_the_performance_dashboard_in_support

  def then_i_should_see_the_total_count_of_candidates
    expect(page).to have_content '3 unique candidates'
    expect(page).not_to have_content 'never signed in'
  end

  def and_i_should_see_the_total_count_of_application_forms
    within '#application-form-count' do
      expect(page).to have_content '3'
    end
  end

  def then_i_see_the_total_number_of_candidates_that_have_not_signed_in
    expect(page).to have_content '5 unique candidates'
    expect(page).to have_content '2 never signed in'
  end

  def when_i_go_a_report_for_a_specific_year
    click_on RecruitmentCycle.cycle_name
  end

  def then_i_only_see_candidates_that_have_signed_in
    expect(page).to have_content '3 unique candidates'
    expect(page).not_to have_content 'never signed in'
  end
end
