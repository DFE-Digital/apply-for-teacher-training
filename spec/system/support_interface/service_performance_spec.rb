require 'rails_helper'

RSpec.feature 'Service performance' do
  include DfESignInHelpers

  around do |example|
    Timecop.freeze(CycleTimetable.apply_1_deadline(2021) - 10.days) do
      example.run
    end
  end

  scenario 'View service statistics' do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system

    when_i_visit_the_performance_dashboard_in_support

    then_i_should_see_the_total_count_of_candidates
    and_i_should_see_the_total_count_of_application_forms

    when_there_are_candidates_that_have_never_signed_in
    and_i_visit_the_performance_dashboard_in_support

    then_i_see_the_total_number_of_candidates_in_the_system

    when_i_go_a_report_for_a_specific_year

    then_i_only_see_candidates_that_signed_up_that_year
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    create_list(:application_form, 3)
  end

  def when_there_are_candidates_that_have_never_signed_in
    Timecop.freeze(RecruitmentCycle.previous_year - 1, 12, 25) do
      create(:candidate)
    end
    Timecop.freeze(RecruitmentCycle.current_year, 1, 5) do
      create_list(:candidate, 2)
    end
  end

  def when_i_visit_the_performance_dashboard_in_support
    visit support_interface_performance_path
    click_on 'Service performance'
  end

  alias_method :and_i_visit_the_performance_dashboard_in_support, :when_i_visit_the_performance_dashboard_in_support

  def then_i_should_see_the_total_count_of_candidates
    expect(page).to have_content '3 unique candidates'
  end

  def and_i_should_see_the_total_count_of_application_forms
    expect(page).to have_content '3 application forms'
  end

  def then_i_see_the_total_number_of_candidates_in_the_system
    expect(page).to have_content '6 unique candidates'
  end

  def when_i_go_a_report_for_a_specific_year
    click_on RecruitmentCycle.cycle_name
  end

  def then_i_only_see_candidates_that_signed_up_that_year
    expect(page).to have_content '5 unique candidates'
  end
end
