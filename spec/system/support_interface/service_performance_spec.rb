require 'rails_helper'

RSpec.feature 'Service performance', mid_cycle: false do
  include DfESignInHelpers

  scenario 'View service statistics' do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system
    and_there_are_applications_matched_with_ucas

    when_i_visit_the_performance_dashboard_in_support

    then_i_should_see_the_total_count_of_candidates
    and_i_should_see_the_total_count_of_application_forms

    when_there_are_candidates_that_have_never_signed_in
    and_i_visit_the_performance_dashboard_in_support

    then_i_see_the_total_number_of_candidates_in_the_system

    when_i_go_a_report_for_a_specific_year

    then_i_only_see_candidates_that_signed_up_that_year

    when_i_visit_ucas_matches_dashboard_in_support
    then_i_should_see_the_total_number_of_ucas_matches
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    create_list(:application_form, 3)
  end

  def when_there_are_candidates_that_have_never_signed_in
    Timecop.freeze(2019, 12, 25) do
      create(:candidate)
    end
    Timecop.freeze(2021, 1, 5) do
      create_list(:candidate, 2)
    end
  end

  def and_there_are_applications_matched_with_ucas
    create_list(:ucas_match, 2)
  end

  def when_i_visit_the_performance_dashboard_in_support
    visit support_interface_performance_path
    click_on 'Service performance'
  end

  alias_method :and_i_visit_the_performance_dashboard_in_support, :when_i_visit_the_performance_dashboard_in_support

  def then_i_should_see_the_total_count_of_candidates
    expect(page).to have_content '5 unique candidates'
  end

  def and_i_should_see_the_total_count_of_application_forms
    expect(page).to have_content '5 application forms'
  end

  def then_i_see_the_total_number_of_candidates_in_the_system
    expect(page).to have_content '8 unique candidates'
  end

  def when_i_go_a_report_for_a_specific_year
    click_on RecruitmentCycle.cycle_name
  end

  def then_i_only_see_candidates_that_signed_up_that_year
    expect(page).to have_content '7 unique candidates'
  end

  def when_i_visit_ucas_matches_dashboard_in_support
    visit support_interface_performance_path
    click_on 'UCAS matches'
  end

  def then_i_should_see_the_total_number_of_ucas_matches
    expect(page).to have_content '2 candidates on Apply with submitted application'
    expect(page).to have_content '2 (100%) candidates matched with UCAS'
  end
end
